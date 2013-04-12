function kviberg-config

  cd $farm/kviberg-config

  if test (count $argv) -eq 0
    return 0
  end

  set -l command $argv[1]
  set -e argv[1]
  set -l func_name "kviberg-config-$command"

  if functions -q $func_name
    eval $func_name $argv
  end

  return $status

end

function kviberg-config-export
  echo '==> Dumping database'
  mysqldump -uroot -t --skip-extended-insert\
            --ignore-table=kviberg-config-development.schema_migrations\
            kviberg-config-development > db/export.sql
  ok; or return 1
end

function kviberg-config-import
  set -l xip 1

  for i in $argv
    switch $i
      case --no-xip
        set -e xip
    end
  end

  echo '==> Recreating database'
  rake db:drop db:create db:schema:load >/dev/null; ok; or return 1
  echo '==> Populating database'
  mysql -uroot kviberg-config-development < db/export.sql; ok; or return 1

  if set -q xip
    echo '==> Inserting debug domains'
    set -l ip_address (ifconfig | grep 'inet ' | grep -v 127.0.0.1 | cut -d ' ' -f 2)
    if test -n "$ip_address"
      for site in 1:dekho 2:bikroy 3:ikman 4:tonaton
        set -l parts (echo $site | tr ':' "\n")
        mysql -uroot kviberg-config-development\
              -e "insert into domains (site_id, domain_name) values ($parts[1], '$parts[2].kviberg.$ip_address.xip.io');"\
              -e "insert into domains (site_id, domain_name) values ($parts[1], '$parts[2].kviberg-mobile.$ip_address.xip.io');"
      end
    end
    ok
  end

  echo '==> Flushing redis'
  redis-cli flushall
  echo '==> Flushing memcached'
  echo 'flush_all' | nc 127.0.0.1 11211
end

function ok
  and echo 'OK'
  or begin
    echo 'FAIL'
    return 1
  end
end
