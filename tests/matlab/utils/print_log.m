function print_log()
  global marbl_log
  dims = size(marbl_log)
  for n=1:dims(1)
    if (size(strtrim(marbl_log(n,:))) == 0)
      fprintf('\n')
    else
      fprintf('%s\n',strtrim(marbl_log(n,:)));
    end % if
  end % for
  clear -global marbl_log
end % function

