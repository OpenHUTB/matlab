classdef OS<handle





    properties(Constant,GetAccess='private')
        simulinkBaseRateTaskPriority=40;
    end

    properties
        name;
        alias;
        maxRealTimePriority=inf;
        minRealTimePriority=-inf;
        minSystemStackSize;
        mainIsAThread;
        isProcessorAware;
        needsAdditionalFiles=0;

        schedulingMode='real-time';
        sections={};


        configSetSettings={};


        includes={};
        includePaths={};
        srcFiles={};
        libraries={};
        compilerOptions={};
        linkerOptions={};
        preProcSymbols={};
    end

    properties(Dependent)
        baseRatePriority;
    end

    properties(Access='private')
        privateBaseRatePriority;
    end


    methods(Access='public')

        function this=OS
        end

        function filterOutProject(h,hPjt)
            if isequal(h.name,'Linux')

                fileToFind=fullfile('$(MATLAB_ROOT)','toolbox','shared','spc','src_ml','extern','src','DAHostLib_Network.c');
                found=h.findInBuildInfoSrc(hPjt.mPM.mProjectBuildInfo.mBuildInfo,fileToFind);
                if~isempty(found)
                    fileToAdd=fullfile('$(MATLAB_ROOT)','toolbox','target','extensions','operatingsystem','linux','src','linuxUDP.c');
                    hPjt.addSourceFiles(fileToAdd);
                    hPjt.addPreprocessorSymbols('_USE_TARGET_UDP_');
                    hPjt.addLinkerOption('-ldl');
                end
            elseif isequal(h.name,'VxWorks')

                fileToFind=fullfile('$(MATLAB_ROOT)','toolbox','shared','spc','src_ml','extern','src','DAHostLib_Network.c');
                found=h.findInBuildInfoSrc(hPjt.mPM.mProjectBuildInfo.mBuildInfo,fileToFind);
                if~isempty(found)
                    fileToAdd=fullfile('$(SUPPORT_PACKAGE_ROOT)','src','vxworksUDP.c');
                    hPjt.addSourceFiles(fileToAdd);
                    hPjt.addPreprocessorSymbols('_USE_TARGET_UDP_');
                    hPjt.addPreprocessorSymbols('_VXWORKS_');
                end

                fileToRemv=fullfile('$(MATLAB_ROOT)','toolbox','coder','rtiostream','src','rtiostreamtcpip','rtiostream_tcpip.c');
                found=h.findInBuildInfoSrc(hPjt.mPM.mProjectBuildInfo.mBuildInfo,fileToRemv);
                if~isempty(found)
                    hPjt.deleteSourceFiles(fileToRemv);
                end
            end
        end
    end


    methods(Access='private')
        function found=findInBuildInfoSrc(h,buildInfo,filename)
            filename=strrep(filename,'$(MATLAB_ROOT)',matlabroot);
            found=[];
            for j=1:length(buildInfo.Src.Files)
                iFile=fullfile(buildInfo.Src.Files(j).Path,buildInfo.Src.Files(j).FileName);
                iFile=strrep(iFile,'$(MATLAB_ROOT)',matlabroot);
                if~isempty(findstr(iFile,filename))
                    found=iFile;
                    break;
                end
            end
        end
    end


    methods
        function obj=set.schedulingMode(obj,mode)
            if~(strcmpi(mode,'real-time')||strcmpi(mode,'free-running'))
                DAStudio.error('ERRORHANDLER:pjtgenerator:InvalidSchedulingMode');
            end
            obj.schedulingMode=lower(mode);
        end

        function mode=get.schedulingMode(obj)
            mode=obj.schedulingMode;
        end

        function priority=get.baseRatePriority(obj)
            priority=obj.privateBaseRatePriority;
        end

        function set.baseRatePriority(obj,priority)




            if((priority<obj.maxRealTimePriority)&&...
                (priority>=obj.minRealTimePriority))
                obj.privateBaseRatePriority=priority;
            else
                DAStudio.error('ERRORHANDLER:pjtgenerator:InvalidPriority',...
                obj.minRealTimePriority,obj.maxRealTimePriority-1);
            end
        end
    end

    methods(Access='public')

        function varargout=addIncludes(obj,includeFile)
            obj.includes=addToCellArray(obj.includes,includeFile);
            if(nargout>0)
                varargout{1}=1;
            end
        end

        function varargout=addLibraries(obj,library)
            obj.libraries=addToCellArray(obj.libraries,library);
            if(nargout>0)
                varargout{1}=1;
            end
        end

        function varargout=addSourceFiles(obj,srcFile)
            obj.srcFiles=addToCellArray(obj.srcFiles,srcFile);
            if(nargout>0)
                varargout{1}=1;
            end
        end

        function varargout=addLinkerOptions(obj,linkerOption)
            obj.linkerOptions=addToCellArray(obj.linkerOptions,...
            linkerOption);
            if(nargout>0)
                varargout{1}=1;
            end
        end

        function varargout=addCompilerOptions(obj,compilerOption)
            obj.compilerOptions=addToCellArray(obj.compilerOptions,...
            compilerOption);
            if(nargout>0)
                varargout{1}=1;
            end
        end

        function varargout=addPreprocessorSymbols(obj,preProcSymbol)
            obj.preProcSymbols=addToCellArray(obj.preProcSymbols,...
            preProcSymbol);
            if(nargout>0)
                varargout{1}=1;
            end
        end

        function varargout=addIncludePaths(obj,includePath)
            obj.includePaths=addToCellArray(obj.includePaths,...
            includePath);
            if(nargout>0)
                varargout{1}=1;
            end
        end


        function ret=getSourceFiles(obj)
            ret=obj.srcFiles;
        end

        function ret=getIncludes(obj)
            ret=obj.includes;
        end

        function ret=getIncludePaths(obj)
            ret=obj.includePaths;
        end

        function ret=getLibraries(obj)
            ret=obj.libraries;
        end

        function ret=getLinkerOptions(obj)
            ret=obj.linkerOptions;
        end

        function ret=getCompilerOptions(obj)
            ret=obj.compilerOptions;
        end

        function ret=getPreprocessorSymbols(obj)
            ret=obj.preProcSymbols;
        end

    end
end


function cellArray=addToCellArray(cellArray,list)

    if~iscell(list)
        cellArray=[cellArray;list];
    else
        cellArray=[cellArray;list(:)];
    end

end

