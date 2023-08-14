function writeMkCfgMakeInfoStructAssignment(h,fid,hasLib,singleCPPMexFile)%#ok<INUSL>





    if nargin<4
        singleCPPMexFile=false;
    end


    fprintf(fid,'%% Additional include directories\n');
    fprintf(fid,'makeInfo.includePath = correct_path_name(allIncPaths);\n');
    fprintf(fid,'\n');


    fprintf(fid,'%% Additional source directories\n');
    fprintf(fid,'makeInfo.sourcePath = correct_path_name(allSrcPaths);\n');
    fprintf(fid,'\n');

    if singleCPPMexFile

        fprintf(fid,'%% Additional sources \n');
        fprintf(fid,'makeInfo.sources = allSrcs;\n');
        fprintf(fid,'\n');
    end

    if hasLib

        fprintf(fid,'%% Additional libraries according to the build type\n');
        fprintf(fid,'makeInfo.linkLibsObjs = correct_path_name(allLibs);\n');
        fprintf(fid,'\n');
    end

