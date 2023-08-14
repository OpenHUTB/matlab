classdef baselink<handle








    properties(SetAccess='public',GetAccess='public')

        timeout=10.0;

        targetinfo=[];
    end
    properties(SetAccess='public',GetAccess='public',Hidden=true)

        StackProfiler=[];
    end

    properties(SetAccess='protected',GetAccess='protected')

        buildtimeout=1000.0;

        mIde2ProcConnectionTimeout=10.0;

        mIdeConnectionID=[];

        mIdeModule=[];
    end









    methods(Access='public')
        function h=baselink(varargin)
            h=initializeClass(h,varargin{:});
        end
        function delete(h,varargin)

        end
        function set(h,prop,value)
            if nargin<3
                error(message('ERRORHANDLER:autointerface:PropertyAndValueNotSpecified'));
            end
            h.(prop)=value;
        end
        function value=get(h,prop)
            if nargin==1
                error(message('ERRORHANDLER:autointerface:PropertyNotSpecified'));
            end
            value=h.(prop);
        end
    end

    methods
        function a=saveobj(h)
            warning(message('ERRORHANDLER:autointerface:WarnOnSavingObjectToMat',linkfoundation.util.getClassName(h,'upper')));
            a=h;
        end
    end




    methods

        function set.timeout(h,val)
            if numel(val)~=1||~isnumeric(val)||val<0,
                error(message('ERRORHANDLER:autointerface:InvalidTimeoutPropertyValue',linkfoundation.util.getClassName(h,'upper')));
            end
            h.timeout=double(val);
        end

        function set.buildtimeout(h,val)
            if numel(val)~=1||~isnumeric(val)||val<0,
                error(message('ERRORHANDLER:autointerface:InvalidBuildTimeoutPropertyValue',linkfoundation.util.getClassName(h,'upper')));
            end
            h.buildtimeout=double(val);
        end

        function set.mIde2ProcConnectionTimeout(h,val)
            if numel(val)~=1||~isnumeric(val)||val<0,
                error(message('ERRORHANDLER:autointerface:InvalidConnectionTimeoutPropertyValue',linkfoundation.util.getClassName(h,'upper')));
            end
            h.mIde2ProcConnectionTimeout=double(val);
        end

        function set.mIdeConnectionID(h,val)
            if numel(val)>1||~isnumeric(val)||rem(val,1)>0||val<0,
                error(message('ERRORHANDLER:autointerface:InvalidConnectionIdPropertyValue',linkfoundation.util.getClassName(h,'upper')));
            end
            h.mIdeConnectionID=val;
        end

        function set.mIdeModule(h,val)
            if numel(val)>1
                error(message('ERRORHANDLER:autointerface:InvalidIdeModulePropertyValue',linkfoundation.util.getClassName(h,'upper')));
            end
            h.mIdeModule=val;
        end

        function varargout=invokeIdeModule(h,methodname,varargin)
            [varargout{1:nargout}]=h.mIdeModule.(methodname)(varargin{1:end});
        end

    end




    methods(Access='protected')
        function errorHandlerNotReached(h)
            stk=dbstack(1);
            error(message('ERRORHANDLER:autointerface:InvalidMethodReached',stk(1).name,linkfoundation.util.getClassName(h,'upper')));
        end
    end




    methods(Abstract)
        oinfo=info(h,opt)
    end
    methods(Abstract,Hidden=true)
        resp=ide_getFileTypeBasedOnExt(h,regname,represent,timeout)
        resp=ide_readLargeData(h,address,datatype,count,timeout)
        ide_writeLargeData(h,address,data,count,timeout)
        resp=ide_getBuildOptionNames(h)
        addr=ide_getCompleteAddress(h,addr)
        resp=proc_regread(h,regname,represent,timeout)
        resp=proc_regwrite(h,regname,represent,timeout)
        proc_displayOneProc(h,tgtInfo)
        proc_displayMultiProc(h,tgtInfo)
        ext=ide_getFileExt(h,fileType)
        ext=ide_ifReadWriteSizeLimitReached(h,excep)
        ext=ide_hitok(h)
    end





    methods(Hidden=true)
        logProjectInfo(h,ProjectBuildInfo);
        loadProject(h,ProjectBuildInfo);
        pilStoreTargetInfo(h,ProjectBuildInfo);
        executeProject(h,ProjectBuildInfo);
    end

    methods(Hidden=true,Static=true)

        list=getLinkerOptions(ProjectBuildInfo);

        list=getCompilerOptions(ProjectBuildInfo,expandTokens);

        function checkPlatformSupport(functionName,supportedPlatformsByAdaptor,adaptorName)
            narginchk(2,3);
            thisPlatform=computer;
            functionName=upper(functionName);


            supportedPlatforms=linkfoundation.util.getPlatformsSupported;


            supportedByLink=any(strcmpi(thisPlatform,{supportedPlatforms{1:2:end}}));
            if~supportedByLink
                ex=MException('ERRORHANDLER:autointerface:PlatformNotSupportedByProduct',DAStudio.message('ERRORHANDLER:autointerface:PlatformNotSupportedByProduct',functionName,thisPlatform));
                throwAsCaller(ex);
            end


            supportedByAdaptor=any(strcmpi(thisPlatform,supportedPlatformsByAdaptor));
            if~supportedByAdaptor
                if nargin==2
                    adaptorName=functionName;
                end
                ideName=idelinkext(adaptorName,'vendor-ide-full');
                idx=find(strcmpi(thisPlatform,{supportedPlatforms{1:2:end}}));
                platformDesc=supportedPlatforms{idx*2};
                ex=MException('ERRORHANDLER:autointerface:PlatformNotSupportedByAdaptor',DAStudio.message('ERRORHANDLER:autointerface:PlatformNotSupportedByAdaptor',...
                functionName,platformDesc,ideName));
                throwAsCaller(ex);
            end
        end

        function checkOutLicense(args)


            product.licensekey='RTW_embedded_coder';
            product.name='Embedded Coder';

            for i=1:2:length(args)
                prop=lower(args{i});
                val=args{i+1};
                if isequal(prop,'isrttonly')&&val

                    return
                elseif isequal(prop,'ishostonly')&&val


                    product.licensekey='matlab_coder';
                    product.name='MATLAB Coder';
                end
            end

            try
                licenseAvailable=builtin('license','checkout',product.licensekey);
            catch ex %#ok<NASGU>
                licenseAvailable=false;
            end
            if~licenseAvailable
                DAStudio.error('ERRORHANDLER:autointerface:noLicense',product.name);
            end
        end
    end
end


