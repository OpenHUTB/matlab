cd(fileparts(mfilename('fullpath')));
setup;
workDir=fullfile(tempdir,sprintf('work_cnn5_sched_%s',getExtension));
delete(fullfile(workDir,'/*'));
mkdir(workDir);
cd(workDir);
scratch;
schedulerTestbench2;

