classdef(Sealed=true)AdaptorRegistry<handle






    properties(SetAccess='private')
        Tag;
        Toolchains;



    end

    properties(Constant)

    end











    methods(Access='private')

        function This=AdaptorRegistry
        end
    end

    methods(Static=true)
        function SingleObj=manageInstance(action,Tag)


            mlock;
            persistent LocalStaticObj;

            Idx=0;
            for i=1:length(LocalStaticObj)
                if~isempty(strmatch(Tag,LocalStaticObj(i).Handle.Tag));
                    Idx=i;
                    break;
                end
            end

            switch action
            case{'create','get'}

                if Idx==0
                    Idx=length(LocalStaticObj)+1;
                    LocalStaticObj(Idx).Handle=linkfoundation.pjtgenerator.AdaptorRegistry;
                    LocalStaticObj(Idx).Handle.Tag=Tag;
                end

                SingleObj=LocalStaticObj(Idx).Handle;

            case 'destroy'
                if Idx~=0
                    delete(LocalStaticObj(Idx).Handle);
                    LocalStaticObj(Idx)=[];
                end
                if isempty(LocalStaticObj)
                    clear LocalStaticObj;
                end
                SingleObj=[];

            otherwise

                SingleObj=[];
                return;
            end
        end
    end


    methods(Access='private')




        function Adaptor=loadAdaptor(reg,AdaptorFile)%#ok<MANU>

            if isa(AdaptorFile,'function_handle')
                Adaptor=AdaptorFile();
                Adaptor.FileName=AdaptorFile;
            else
                [PathStr,FileName]=fileparts(AdaptorFile);
                Pwd=cd(PathStr);

                Adaptor=eval(FileName);
                Adaptor.FileName=AdaptorFile;

                cd(Pwd);
            end
        end


        function idx=getAdaptorIdx(reg,AdaptorFileName)

            idx=[];
            if isempty(AdaptorFileName)
                DAStudio.error('ERRORHANDLER:pjtgenerator:EmptyAdaptorFileName');
            end


            for i=1:length(reg.Toolchains)
                if(isa(AdaptorFileName,'function_handle'))
                    if isequal(AdaptorFileName,reg.Toolchains(i).Adaptor.FileName)
                        idx=i;
                        return;
                    end
                else
                    if~isempty(strmatch(AdaptorFileName,reg.Toolchains(i).Adaptor.FileName,'exact'))
                        idx=i;
                        return;
                    end
                end
            end
        end


        function AdaptorFileName=getAdaptorFileName(reg,AdaptorName)

            AdaptorFileName=[];

            for i=1:length(reg.Toolchains)
                if~isempty(strmatch(AdaptorName,reg.Toolchains(i).Adaptor.Name,'exact'))
                    AdaptorFileName=reg.Toolchains(i).Adaptor.FileName;
                    return;
                end
            end
        end


        function adaptorInfo=getAdaptorInfo(reg,adaptorName)
            found=1;
            adaptorFile=reg.getAdaptorFileName(adaptorName);
            if isempty(adaptorFile)
                found=0;
            else
                idx=reg.getAdaptorIdx(adaptorFile);
                if isempty(idx)
                    found=0;
                else
                    adaptorInfo=reg.Toolchains(idx).Adaptor;
                end
            end
            if~found
                DAStudio.error('ERRORHANDLER:pjtgenerator:AdaptorNotFound',adaptorName);
            end
        end

    end
end
