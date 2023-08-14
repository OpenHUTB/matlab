


...
...
...
...
...
...
...
...
...
...
...
...
...
...
classdef CacheHandler<handle
    properties(Access=private)
        mModelH double
        mBlockH double
        mAnalysisMode char
        mCacheDirName char
        mCacheDirRootLevel char
        mCacheDirFullPath char
        mMarkerFileNameFull char


        mIsXIL logical
        mIsUnpackCalled logical
    end

    properties(Access=private,Constant)
        mMarkerFileName='ModelRepresentationMarker.xml';
        mMarkerNodeName_Root='model';
        mMarkerNodeName_Component='component';
        mMarkerNodeName_ComponentName='name';
        mMarkerNodeName_Checksum='checksum';
        mMarkerNodeName_DVO='dvo';
        mMarkerNodeName_ModelMap='modelmap';
        mMarkerNodeName_xilDB='xilDB';
    end

    methods(Access=public)





        function obj=CacheHandler(modelH,blockH,analysisMode,isXIL)
            if nargin<4
                isXIL=false;
            end

            obj.setCurrentAnalysisComponent(modelH,blockH,analysisMode,isXIL);
        end
    end

    methods(Access=public,Hidden)










        function status=updateSLDVCacheMarkerFile(obj,componentChecksum)
            status=true;

            if nargin<2
                componentChecksum=obj.getCacheChecksum();
            else


                check=isstruct(componentChecksum);
                assert(check,'SldvCompat:InvalidArguments','Expecting non-empty arguments(struct)');
                check=(~isempty(componentChecksum.dvoChecksum)&&ischar(componentChecksum.dvoChecksum))&&...
                (~isempty(componentChecksum.modelMapChecksum)&&ischar(componentChecksum.modelMapChecksum));
                assert(check,'SldvCompat:InvalidArguments','Expecting non-empty checksum arguments');
            end

            try
                obj.updateMarkerFile(componentChecksum);
            catch MEx
                status=false;
            end
        end

        function[status,msg,msgID]=packCacheToSLXC(obj,wasTargetOutOfDate)
            status=true;msg='';msgID='';


            if~obj.mIsUnpackCalled
                status=false;
                msgID='Sldv:Compatibility:CachingModelRepresentationFailed';
                msg=getString(message('Sldv:Setup:CachingModelRepresentationFailed'));
                return;
            end
            try
                mdlName=get_param(obj.mModelH,'Name');
                builtin('_packSLCacheSLDV',mdlName,obj.getSLCacheMode(),wasTargetOutOfDate);
                obj.mIsUnpackCalled=false;
            catch MEx
                status=false;
                msgID='Sldv:Compatibility:CachingModelRepresentationFailed';
                msg=getString(message('Sldv:Setup:CachingModelRepresentationFailed'));
                msg=sprintf('%s. %s',msg,MEx.message);
            end
        end

        function[status,msg,msgID]=unpackCacheFromSLXC(obj)
            status=true;msg='';msgID='';
            try
                mdlName=get_param(obj.mModelH,'Name');
                builtin('_unpackSLCacheSLDV',mdlName,obj.getSLCacheMode());
                obj.mIsUnpackCalled=true;
            catch MEx
                status=false;
                msgID='Sldv:Compatibility:ReadingModelRepresentationFailed';
                msg=getString(message('Sldv:Setup:ReadingModelRepresentationFailed'));
                msg=sprintf('%s. %s',msg,MEx.message);
            end
        end
    end

    methods(Access=private)
        function setCurrentAnalysisComponent(obj,modelH,blockH,analysisMode,isXIL)
            obj.mModelH=modelH;
            obj.mBlockH=blockH;
            obj.mAnalysisMode=analysisMode;
            obj.mIsXIL=isXIL;

            assert(any(strcmp({'TestGeneration','PropertyProving','DesignErrorDetection'},analysisMode)),'Invalid analysis mode');


            [obj.mCacheDirFullPath,obj.mCacheDirName,obj.mCacheDirRootLevel]=...
            sldvprivate('getSldvCacheDIR',obj.mModelH,obj.mBlockH,obj.mAnalysisMode,obj.mIsXIL);







            obj.mMarkerFileNameFull=fullfile(obj.mCacheDirRootLevel,obj.mMarkerFileName);

            obj.mIsUnpackCalled=false;
        end

        componentChecksum=getCacheChecksum(obj);

        updateMarkerFile(obj,componentChecksum)

        createMarkerFile(obj)

        function[fName,fExt]=getTranslationDataFileName(obj)
            fName=[obj.mCacheDirName,'_translationData'];
            fExt='.mat';
        end

        function[fName,fExt]=getTranslationDvoFileName(obj)
            fName=[obj.mCacheDirName,'_translationDvo'];
            fExt='.dvo';
        end

        function[fName,fExt]=getXILDataFileName(obj)
            fName=[obj.mCacheDirName,'_sldv_cc'];
            fExt='.mat';
        end

        function slCacheMode=getSLCacheMode(obj)
            if obj.mIsXIL
                slCacheMode=slcache.Modes.SLDV_XIL_TG;
                return;
            end

            switch obj.mAnalysisMode
            case 'TestGeneration'
                slCacheMode=slcache.Modes.SLDV_TG;
            case 'PropertyProving'
                slCacheMode=slcache.Modes.SLDV_PP;
            case 'DesignErrorDetection'
                slCacheMode=slcache.Modes.SLDV_DED;
            otherwise
                assert(true,'Invalid SLDV Cache Mode');
            end
        end
    end


    methods(Access=public,Hidden)
        function check=verifyMarkerFile(obj,systemChecksum)
            sysName=obj.mCacheDirName;

            if nargin<2
                systemChecksum=obj.getCacheChecksum();
            end


            dvoChecksum=systemChecksum.dvoChecksum;
            modelMapChecksum=systemChecksum.modelMapChecksum;


            import matlab.io.xml.dom.*


            xmlDoc=parseFile(Parser,obj.mMarkerFileNameFull);


            components=xmlDoc.getElementsByTagName(obj.mMarkerNodeName_Component);
            componentList=logical.empty(0,components.getLength);
            for idx=0:components.getLength-1
                comp=components.item(idx);
                compName=comp.getElementsByTagName(obj.mMarkerNodeName_ComponentName);
                compName=compName.item(0);
                componentList(idx+1)=strcmp(sysName,compName.getFirstChild.getData);
            end
            check=(nnz(componentList)==1);



            if check
                idx=find(componentList==true);
                checksums=xmlDoc.getElementsByTagName(obj.mMarkerNodeName_Checksum);
                cs=checksums.item(idx-1);
                cs_dvo=cs.getElementsByTagName(obj.mMarkerNodeName_DVO);
                cs_dvo=cs_dvo.item(0);
                check=strcmp(dvoChecksum,cs_dvo.getFirstChild.getData);
                if check
                    cs_modelMap=cs.getElementsByTagName(obj.mMarkerNodeName_ModelMap);
                    cs_modelMap=cs_modelMap.item(0);
                    check=strcmp(modelMapChecksum,cs_modelMap.getFirstChild.getData);
                end
                if obj.mIsXIL
                    cs_xilDB=cs.getElementsByTagName(obj.mMarkerNodeName_xilDB);
                    cs_xilDB=cs_xilDB.item(0);
                    check=strcmp(modelMapChecksum,cs_xilDB.getFirstChild.getData);
                end
            end
        end

        function markerFile=getMarkerFileFullName(obj)
            markerFile=obj.mMarkerFileNameFull;
        end
    end
end
