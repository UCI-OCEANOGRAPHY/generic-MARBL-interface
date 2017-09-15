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

% need to wrap this in spmd(1) to prevent threading
spmd(1)
mex_marbl_driver('put setting', 'ciso_on = .true.')
tracer_cnt = mex_marbl_driver('init', delta_z, zw, zt);
mex_marbl_driver('print log')
mex_marbl_driver('shutdown')
mex_marbl_driver('print timers')
tracer_cnt
end
