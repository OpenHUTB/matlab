


classdef SubSystemInterfaceObject<slci.results.FunctionInterfaceObject

    properties(Access=protected)

        fSubsystem;
    end

    methods(Access=public,Hidden=true)


        function obj=SubSystemInterfaceObject(aKey,aName,aSubsystem,aType)
            if nargin==0

                DAStudio.error('Slci:results:DefaultConstructorError',...
                'FUNCTION INTERFACE');
            end
            obj=obj@slci.results.FunctionInterfaceObject(aKey,aName,aType);

            obj.setSubsystem(aSubsystem);
        end


        function setSubsystem(obj,aSubsystem)
            obj.fSubsystem=aSubsystem;
        end


        function aName=getSubsystem(obj)
            aName=obj.fSubsystem;
        end
    end

    methods(Access=public,Hidden=true)

        function subsysName=getDispSubName(obj)
            subsysName={};
            if~isempty(obj.fSubsystem)
                subName=strrep(obj.fSubsystem,'<','&lt;');
                subName=strrep(subName,'>','&gt;');
                subName=strrep(subName,'\','\\');
                subsysName=strtrim(split(subName,','));
            end
        end


        function linkSID=getLink(obj,datamgr)
            modelFile=datamgr.getMetaData('ModelName');


            modellink=modelFile;
            linkSID={};
            if~isempty(modellink)
                subsystem=obj.getSubsystem();
                if~isempty(subsystem)
                    try
                        subs=strtrim(split(subsystem,','));
                        for i=1:numel(subs)
                            linkSID{end+1}=Simulink.ID.getSID(subs{i});%#ok
                        end
                    catch

                    end
                else
                    linkSID{end+1}=modellink;
                end
            end

        end


        function callback=getCallback(obj,datamgr)


            link=obj.getLink(datamgr);
            if isempty(link)
                callback=obj.getDispName();
            else
                modelFileName=datamgr.getMetaData('ModelFileName');
                encodedModelFileName=slci.internal.encodeString(...
                modelFileName,'all','encode');

                if isempty(obj.getSubsystem)
                    assert(numel(link)==1);
                    callback=slci.internal.ReportUtil.appendCallBack(...
                    obj.getDispName(),encodedModelFileName,link{1});
                else
                    subNames=obj.getDispSubName();
                    assert(numel(link)==numel(subNames));
                    callback=[];
                    for i=1:numel(link)
                        callback=[callback,slci.internal.ReportUtil.appendCallBack(...
                        subNames{i},encodedModelFileName,link{i})];%#ok
                        if(i~=numel(link))
                            callback=[callback,', '];%#ok
                        end
                    end
                    callback=[obj.getDispName(),' for ',callback];
                end
            end
        end
    end
end
