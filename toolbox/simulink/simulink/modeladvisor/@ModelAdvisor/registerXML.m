function registerXML(fileName,argin)

    import matlab.io.xml.dom.*



    if isempty(fileName)
        argin.exclusionCellArray=[];
        return;
    end

    isslx=false;
    maObj=isa(argin,'Simulink.ModelAdvisor');
    if maObj
        [~,fName,ext]=fileparts(get_param(bdroot(argin.system),'filename'));
        if isempty(fName)
            isslx=true;
        else
            isslx=strcmp(ext,'.slx');
        end

        if isslx&&(exist(fileName,'file')==0)
            Simulink.slx.extractFileForPart(bdroot(argin.system),'/advisor/exclusions.xml');
        end
    end
    if exist(fileName,'file')~=0
        tree=parseFile(Parser,fileName);
    elseif isslx
        return
    else
        if isa(argin,'Simulink.ModelAdvisor')
            DAStudio.message('ModelAdvisor:engine:ModelExclusionFileNotFound',fileName)
        else
            DAStudio.message('ModelAdvisor:engine:DefaultExclusionFileNotFound',fileName)

        end
        return;
    end
    xRoot=tree.getDocumentElement;
    sysNode=xRoot.getElementsByTagName('System');

    if isa(argin,'Simulink.ModelAdvisor')
        argin.exclusionCellArray=[];
    end
    checkTypeValue='ModelAdvisor';
    if strcmp(argin.CustomTARootID,'com.mathworks.Simulink.CloneDetection.CloneDetection')
        checkTypeValue='CloneDetection';
    end
    for i=0:sysNode.getLength-1
        exclusionArray=[];
        sysAttributes=sysNode.item(i).getAttributes;
        if~isempty(sysAttributes.item(0))
            sysName=char(sysAttributes.item(0).getNodeValue);
        else
            return;
        end
        if isa(argin,'Simulink.ModelAdvisor')
            loadedSys=getfullname(argin.system);
            loadedSys=regexprep(loadedSys,sprintf('\n'),' ');
            if regexp(loadedSys,sysName)
                exclusionArray=[exclusionArray,ModelAdvisor.constructExclusionObjArray(sysNode.item(i),checkTypeValue)];
            end
        else
            exclusionArray=[exclusionArray,ModelAdvisor.constructExclusionObjArray(sysNode.item(i),checkTypeValue)];
        end

        if isa(argin,'Simulink.ModelAdvisor')
            for j=1:length(exclusionArray)
                for k=1:length(exclusionArray(j).Rules)
                    if(strcmpi(exclusionArray(j).Rules(k).Type,'Subsystem')||...
                        strcmpi(exclusionArray(j).Rules(k).Type,'Block'))
                        exclusionArray(j).Rules(k).Value{1}=[bdroot(argin.SystemName),'/',exclusionArray(j).Rules(k).Value{1}];
                    end
                end
            end
            argin.exclusionCellArray=[argin.exclusionCellArray,exclusionArray];
        else
            for e=1:length(exclusionArray)
                exclusionArray(e).Factory='on';
            end
            ModelAdvisor.RegisterExclusion(exclusionArray,sysName);
        end
    end














