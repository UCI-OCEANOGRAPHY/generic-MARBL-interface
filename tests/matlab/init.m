% To run, launch matlab from this directory and run
% >> run('init.m')
addpath('../..')

% need to wrap this in spmd(1) to prevent threading
spmd(1)
mex_marbl_driver('init')
mex_marbl_driver('print log')
mex_marbl_driver('shutdown')
mex_marbl_driver('print timers')
end
