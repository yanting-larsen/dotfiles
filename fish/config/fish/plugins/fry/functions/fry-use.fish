function fry-use --description 'Use the ruby given by <name>'
  if test (count $argv) -eq 0
    echo 'fry-use: No <name> given.'
    echo
    echo 'Available rubies:'
    fry-rubies
    return 1
  end

  set -l name $argv[1]
  set -l ruby (fry-ls | grep -m 1 $name)

  if test -z "$ruby"
    echo "fry-use: Unknown ruby '$name' given."
    echo
    echo 'Available rubies:'
    fry-rubies
    return 1
  end

  ln -sfn $fry_rubies/$ruby $fry_rubies/current
  echo "Switched to ruby '$ruby'"
end
