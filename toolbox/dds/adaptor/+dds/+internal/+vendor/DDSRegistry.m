classdef DDSRegistry<handle



    properties(Constant,Hidden)
        PACKAGENAME='dds.internal.vendor';
        FUNCTIONSTART='register';
        REQUIREDFIELDS={'Key','DisplayName','DefaultToolchain','AnnotationKey',...
        'SetupModel','ImportXML','ExportToXML',...
        'VendorPostCompileValidation',...
        'GenerateIDLAndXMLFiles',...
        'GenerateServices'};


    end


    methods(Static)
        function lst=getListOfRegistryFunctions()

            metaInfo=meta.package.fromName(dds.internal.vendor.DDSRegistry.PACKAGENAME);
            functionList=metaInfo.FunctionList;
            lst=[];
            for i=1:numel(functionList)
                name=functionList(i).Name;
                if startsWith(name,dds.internal.vendor.DDSRegistry.FUNCTIONSTART)
                    lst{end+1}=[dds.internal.vendor.DDSRegistry.PACKAGENAME,'.',functionList(i).Name];%#ok<AGROW>
                end
            end
        end

        function[need,newlst]=needToReRegister()



            persistent CurrentList;
            newlst=dds.internal.vendor.DDSRegistry.getListOfRegistryFunctions();
            need=~isequal(CurrentList,newlst);
            if need
                CurrentList=newlst;
            end
        end

        function[allFound,missingFlds]=checkIfAllFieldsFound(regReturn)


            validateattributes(regReturn,{'struct'},{'scalar'});
            flds=fields(regReturn);
            found=ismember(dds.internal.vendor.DDSRegistry.REQUIREDFIELDS,flds);
            allFound=all(found);
            missingFlds=dds.internal.vendor.DDSRegistry.REQUIREDFIELDS(~found);
        end

        function register(map,lst)



            for i=1:numel(lst)
                try
                    funcH=str2func(lst{i});
                    regReturn=funcH();
                    [found,missingFlds]=dds.internal.vendor.DDSRegistry.checkIfAllFieldsFound(regReturn);
                    if~found
                        dds.internal.simulink.Util.warningNoBacktrace(message('dds:vendor:NotAllFieldsFound',lst{i},strjoin(missingFlds,',')));
                        continue;
                    end
                    if ismember(regReturn.Key,map.keys)
                        dds.internal.simulink.Util.warningNoBacktrace(message('dds:vendor:KeyRegistered',lst{i},regReturn.Key));
                        continue;
                    else

                        map(regReturn.Key)={regReturn};
                    end
                catch ex
                    dds.internal.simulink.Util.warningNoBacktrace(message('dds:vendor:RegisterFuncError',lst{i},ex.message));
                end
            end
        end

        function map=getCurrentMap()

            persistent CurrentMap;
            [need,lst]=dds.internal.vendor.DDSRegistry.needToReRegister();
            if isempty(CurrentMap)||need
                CurrentMap=containers.Map();
                dds.internal.vendor.DDSRegistry.register(CurrentMap,lst);
            end
            map=CurrentMap;
        end
    end

    methods
        function obj=DDSRegistry

        end

        function lst=getVendorList(~)

            map=dds.internal.vendor.DDSRegistry.getCurrentMap();
            keys=map.keys;
            numEntries=numel(keys);
            if numEntries<1
                lst=[];
                return;
            end
            lst=struct('Key',keys);
            for i=1:numEntries
                entry=map(keys{i});
                lst(i).DisplayName=entry{1}.DisplayName;
            end
        end

        function info=getEntryFor(~,key)


            try
                map=dds.internal.vendor.DDSRegistry.getCurrentMap();
                entry=map(key);
                info=entry{1};
            catch
                throwAsCaller(MException(message('dds:vendor:NoVendorFoundFor',key)));
            end
        end
    end
end


