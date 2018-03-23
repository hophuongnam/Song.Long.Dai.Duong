for i in {1..799}; do
#  y=$i
#  if (( $i < 100 )); then
#    y=0$i
#  fi
#  if (( $i < 10 )); then
#    y=00$i
#  fi
#  ruby ./build_dict_ddsl.rb $y
  ruby ./build_dict_ddsl_json.rb $i
done
