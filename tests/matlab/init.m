% To run, launch matlab from this directory and run
% >> run('init.m')
addpath('../..')

% set up simple column to pass to init
clear nlev delta_z zw zt
nlev = 5;
delta_z(1) = 1;
zw(1) = 1;
zt(1) = 0.5;
for n=2:nlev
  delta_z(n) = 1;
  zw(n) = zw(n-1) + delta_z(n);
  zt(n) = 0.5*(zw(n-1) + zw(n));
end

global marbl_log
mex_marbl_driver('put setting', 'ciso_on = .true.')
[marbl_log, tracer_cnt] = mex_marbl_driver('init', delta_z, zw, zt);
print_log()
mex_marbl_driver('shutdown')
%mex_marbl_driver('print timers')
tracer_cnt

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

