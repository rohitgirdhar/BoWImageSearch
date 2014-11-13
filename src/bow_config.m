if ~isdeployed
    run('~/software/vlfeat/toolbox/vl_setup');
    run('~/software/vlg/toolbox/vlg_setup');
    addpath(genpath('.'));
end

