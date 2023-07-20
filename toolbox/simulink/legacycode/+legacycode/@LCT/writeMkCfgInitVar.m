function writeMkCfgInitVar(h,fid,hasLib,singleCPPMexFile)%#ok<INUSL>




    if nargin<4
        singleCPPMexFile=false;
    end


    fprintf(fid,'%% Declare cell arrays for storing the paths found\n');
    fprintf(fid,'allIncPaths = {};\n');
    fprintf(fid,'allSrcPaths = {};\n');
    if singleCPPMexFile
        fprintf(fid,'allSrcs = {};\n');
    end
    fprintf(fid,'\n');


    if hasLib
        fprintf(fid,'%% Get the build type\n');
        fprintf(fid,'isSimTarget = is_simulation_target();\n');
        fprintf(fid,'allLibs = {};\n');
        fprintf(fid,'\n');
    end
    fprintf(fid,'\n');
