classdef Builder<handle

    properties
        BuildDir=""
        BuildProject=""

        ValidNameStyle="Default"

        DatatypeMapping=strings(0);

ArchModelExtIDMap

ProjectPath
RootProject

IntfExtIDMap

ProjectSLDDPath
ProjectSLDD
ProjectSLDDName

        AllModelNames=[]
        AllModelPaths=[]
        AllInterfaceNames=[]
        AllEnumNames=[]

        ReqFileName=""

        ReqFile=[]
        AllLinkSets=[]

        Profiles=[]

Stats
    end

    methods
        function vName=makeValidName(this,name)
            if strcmpi(this.ValidNameStyle,"underscore")
                name=strrep(name," ","_");
                name=regexprep(name,'(_)\1+','');
            end

            vName=matlab.lang.makeValidName(name);
            eN=exist(vName);%#ok
            if eN>0&&eN~=7
                vName=vName+"_1";
            end
        end

        function this=Builder(buildDir,buildProj,dtypeMapping,vNameStyle)
            this.BuildDir=buildDir;
            this.BuildProject=buildProj;

            this.DatatypeMapping=containers.Map;
            this.ValidNameStyle=vNameStyle;

            for k=1:size(dtypeMapping,1)
                this.DatatypeMapping(dtypeMapping(k,1))=...
                dtypeMapping(k,2);
            end

            pPath=buildDir+filesep+buildProj;
            this.RootProject=matlab.project.createProject(...
            'Name',buildProj,'Folder',pPath);
            this.ProjectPath=this.RootProject.RootFolder;
            this.RootProject.Name=buildProj;

            this.ArchModelExtIDMap=containers.Map;
            this.IntfExtIDMap=containers.Map;

            this.ProjectSLDDName=this.makeValidName(buildProj)+"_DD.sldd";
            ddFile=this.ProjectPath+filesep+this.ProjectSLDDName;
            this.ProjectSLDD=systemcomposer.createDictionary(ddFile);
            this.ProjectSLDDPath=ddFile;
            this.RootProject.addFile(ddFile);

            this.Stats.NumProjectFolders=0;
            this.Stats.NumArchitectureModels=0;

            this.Stats.NumArchitecturePorts=0;
            this.Stats.NumComponents=0;
            this.Stats.NumConnectors=0;
            this.Stats.NumInterfaces=0;

            this.Stats.NumRequirements=0;
            this.Stats.NumReqLinks=0;

            this.Stats.NumProfiles=0;
            this.Stats.NumStereotypes=0;
            this.Stats.NumStereotypeProps=0;
            this.Stats.NumStereotypesApplied=0;
            this.Stats.NumStereotypePropsSet=0;

            populateEnumerations(this);
            populateInterfaces(this);
        end

        function delete(this)
            allMdls=this.ArchModelExtIDMap.values;

            for k=1:length(this.Profiles)
                this.Profiles(k).save;
            end


            sdownFile=this.ProjectPath+filesep+"projectShutdown.m";
            fid=fopen(sdownFile,'w');
            for k=1:length(this.Profiles)
                fprintf(fid,['profTmp = systemcomposer.profile.Profile.find(''',...
                this.Profiles(k).Name,''');\n']);
                fprintf(fid,'if ~isempty(profTmp); profTmp.close(true); end; clear(''profTmp'');\n');
            end
            fclose(fid);
            this.RootProject.addFile(sdownFile);
            this.RootProject.addShutdownFile(sdownFile);

            for k=1:length(allMdls)
                save_system(allMdls{k},'',...
                'SaveDirtyReferencedModels','on');
                close_system(allMdls{k});
            end

            if~isempty(this.ReqFile)
                this.ReqFile.save;
                this.ReqFile.close;
            end

            for k=1:length(this.AllLinkSets)
                this.RootProject.addFile(this.AllLinkSets(k));
            end

            for k=1:length(this.Profiles)
                this.Profiles(k).close;
            end

            this.ProjectSLDD.save;
            this.RootProject.close;
        end

        function populateEnumerations(this)

            ddHdl=Simulink.data.dictionary.open(this.ProjectSLDDName);
            enumTypes=systemcomposer.xmi.CandidateElement.idMap(...
            "getElems","systemcomposer.xmi.CandidateEnum");
            for k=1:length(enumTypes)
                thisEnum=enumTypes{k};
                thisEnum.BuildName=this.makeValidName(thisEnum.Name);
                thisEnum.BuildEnumStrs=thisEnum.EnumStrs;
                this.AllEnumNames=[this.AllEnumNames,string(thisEnum.BuildName)];
                evalin('base',...
                [char(thisEnum.BuildName),...
                '=Simulink.data.dictionary.EnumTypeDefinition;']);

                for p=1:length(thisEnum.EnumStrs)
                    thisEnum.BuildEnumStrs(p)=this.makeValidName(...
                    thisEnum.EnumStrs(p));
                    evalin('base',...
                    ['appendEnumeral(',char(thisEnum.BuildName),','''...
                    ,char(thisEnum.BuildEnumStrs(p)),''',',...
                    int2str(p),')']);
                end
                evalin('base',...
                ['removeEnumeral(',char(thisEnum.BuildName),', 1)']);
                importFromBaseWorkspace(ddHdl,'varList',...
                {char(thisEnum.BuildName)});
                evalin('base',['clear ',char(thisEnum.BuildName)]);
            end
        end

        function populateInterfaces(this)
            intfTypes=systemcomposer.xmi.CandidateElement.idMap(...
            "getElems","systemcomposer.xmi.CandidateInterface");
            allIntfNames=[];
            for k=1:length(intfTypes)
                thisIntf=intfTypes{k};
                if thisIntf.doBuild()
                    allIntfNames=[allIntfNames,this.makeValidName(thisIntf.Name)];%#ok
                end
            end
            if~isempty(allIntfNames)
                allNamesMerged=[this.AllEnumNames,allIntfNames];
                allNamesMerged1=matlab.lang.makeUniqueStrings(...
                allNamesMerged,[false(1,length(this.AllEnumNames)),true(1,length(allIntfNames))],namelengthmax);
                allIntfNames=allNamesMerged1(length(this.AllEnumNames)+1:end);

                intfIdx=1;
                for k=1:length(intfTypes)
                    thisIntf=intfTypes{k};
                    if thisIntf.doBuild()
                        thisIntf.BuildName=allIntfNames(intfIdx);
                        intfIdx=intfIdx+1;
                    end
                end
                for k=1:length(intfTypes)
                    thisIntf=intfTypes{k};
                    if thisIntf.doBuild()
                        thisIntf.buildZCInterface(this);
                    end
                end
            end
        end

        function mn=getModelName(this,mName)
            if mName==""
                mName="Architecture";
            end

            mn=this.makeValidName(mName);

            this.AllModelNames=matlab.lang.makeUniqueStrings(...
            [this.AllModelNames,mn],[false(1,length(this.AllModelNames)),true],namelengthmax);
            mn=this.AllModelNames(end);
        end

        function createProjectFolder(this,candProj)
            if~isempty(candProj.BuildParentPackage)
                candProjName=candProj.BuildName;

                candProj.ZCProjectFolder=...
                candProj.BuildParentPackage.ZCProjectFolder+filesep+candProjName;
                projFolderPath=this.ProjectPath+filesep+candProj.ZCProjectFolder;
                mkdir(projFolderPath);

                this.RootProject.addPath(projFolderPath);

                this.Stats.NumProjectFolders=this.Stats.NumProjectFolders+1;
            end
        end

        function slMdlHdl=createSimulinkModel(this,candArch)
            tempMdlName=this.BuildProject+"_tmp";
            new_system(tempMdlName,"Architecture");
            tempMdlZCM=get_param(tempMdlName,'SystemComposerModel');
            tempMdlZCM.linkDictionary(this.ProjectSLDDPath);
            for k=1:length(this.Profiles)
                tempMdlZCM.applyProfile(this.Profiles(k).Name)
            end

            candArchName=this.getModelName(candArch.Name);
            tmpComp=tempMdlZCM.Architecture.addComponent(char(candArchName));
            candArch.prelimBuildPorts(tmpComp.Architecture,this);

            candArch.ZCHandle=tmpComp.Architecture;

            this.applyStereotypes(candArch);
            this.createParameters(candArch);

            candProj=candArch.ParentPackage;
            slMdlPath=this.ProjectPath+...
            candProj.ZCProjectFolder+filesep+candArchName+".slx";

            this.AllModelPaths=[this.AllModelPaths,slMdlPath];
            tmpComp.createSimulinkBehavior(char(slMdlPath));
            this.RootProject.addFile(slMdlPath);
            candArch.SimulinkModelName=candArchName;

            close_system(tempMdlName,0);
            slMdlHdl=load_system(candArchName);
            this.ArchModelExtIDMap(candArch.ExtElementID)=slMdlHdl;

            set_param(slMdlHdl,'HasSystemComposerArchInfo','on');
            candArch.ZCHandle=get_param(slMdlHdl,'SystemComposerArchitecture');
            set_param(slMdlHdl,'HasSystemComposerArchInfo','off');
            candArch.ZCHandle.ExternalUID=candArch.ExtElementID;

            this.Stats.NumArchitectureModels=this.Stats.NumArchitectureModels+1;
        end

        function archMdl=createArchitectureModel(this,candArch)
            archMdlName=this.getModelName(candArch.Name);

            archMdl=systemcomposer.createModel(archMdlName);
            archMdl.linkDictionary(this.ProjectSLDDPath);
            for k=1:length(this.Profiles)
                archMdl.applyProfile(this.Profiles(k).Name)
            end

            candProj=candArch.ParentPackage;
            archMdlPath=this.ProjectPath+...
            candProj.ZCProjectFolder+filesep+archMdlName+".slx";
            this.AllModelPaths=[this.AllModelPaths,archMdlPath];
            save_system(archMdl.SimulinkHandle,archMdlPath);
            this.RootProject.addFile(archMdlPath);

            this.ArchModelExtIDMap(candArch.ExtElementID)=archMdl.SimulinkHandle;

            this.Stats.NumArchitectureModels=this.Stats.NumArchitectureModels+1;
        end

        function comp=createComponent(this,archHdl,comp)
            compName=comp.Name;
            if compName==""

                compName=comp.ReferenceArch.Name;
            end
            if compName==""

                compName="Component";
            end

            compName=char(compName);

            compName=strrep(compName,'/','_');

            cComps=archHdl.Components;


            otherNames=[];
            for k=1:length(cComps)
                otherNames=[otherNames,string(cComps(k).Name)];%#ok
            end

            cn=matlab.lang.makeUniqueStrings(...
            [otherNames,string(compName)],...
            [false(1,length(otherNames)),true]);
            compName=cn(end);

            comp=archHdl.addComponent(char(compName));
            this.Stats.NumComponents=this.Stats.NumComponents+1;
        end

        function aP=createPort(this,archHdl,portName,portDir)
            aP=archHdl.addPort(char(portName),char(portDir));
            this.Stats.NumArchitecturePorts=this.Stats.NumArchitecturePorts+1;
        end

        function conn=createConnector(this,srcPort,dstPort)
            conn=srcPort.connect(dstPort);
            this.Stats.NumConnectors=this.Stats.NumConnectors+1;
        end

        function intf=createInterface(this,intfExtID,intfName)
            assert(~this.IntfExtIDMap.isKey(intfExtID));
            intf=this.ProjectSLDD.addInterface(char(intfName));
            this.IntfExtIDMap(intfExtID)=intf;
            this.Stats.NumInterfaces=this.Stats.NumInterfaces+1;
        end

        function intf=lookupInterfaceFromExtID(this,intfExtID)
            intf=[];
            if this.IntfExtIDMap.isKey(intfExtID)
                intf=this.IntfExtIDMap(intfExtID);
            end
        end

        function archMdlName=lookupModelNameFromExtID(this,candArchExtID)
            archMdl=this.ArchModelExtIDMap(candArchExtID);
            archMdlName=get_param(archMdl,'Name');
        end

        function recAddRequirementToSet(this,req,reqParent)
            req.ReqID=strrep(req.ReqID,'#','');

            thisReq=reqParent.add('Id',req.ReqID,...
            'Summary',req.Text);
            req.ZCHandle=thisReq;
            this.Stats.NumRequirements=this.Stats.NumRequirements+1;
            for k=1:length(req.ChildRequirements)
                recAddRequirementToSet(...
                this,req.ChildRequirements(k),thisReq);
            end
        end

        function createProfiles(this,candProfiles)
            for k=1:length(candProfiles)
                thisProf=candProfiles(k);
                if~isempty(thisProf.Stereotypes)



                    thisProf.fixupStereotypeNames(this);



                    for p=1:length(thisProf.Stereotypes)
                        thisProf.Stereotypes(p).uniquePropNames(this);
                    end


                    newProfName=this.makeValidName(char(thisProf.Name));
                    newProf=systemcomposer.profile.Profile.createProfile(newProfName);
                    this.Profiles=[this.Profiles,newProf];
                    profFile=save(newProf,char(this.ProjectPath));
                    this.RootProject.addFile(profFile);
                    thisProf.FinalName=newProfName;

                    this.Stats.NumProfiles=this.Stats.NumProfiles+1;


                    for p=1:length(thisProf.Stereotypes)
                        st=thisProf.Stereotypes(p);
                        st.ZCHandle=newProf.addStereotype(st.Name);
                        props=st.Properties;
                        this.Stats.NumStereotypes=this.Stats.NumStereotypes+1;

                        for m=1:length(props)
                            st.ZCHandle.addProperty(...
                            char(props(m).FinalName),'Type','string');

                            this.Stats.NumStereotypeProps=this.Stats.NumStereotypeProps+1;
                        end
                    end


                    for p=1:length(thisProf.Stereotypes)
                        st=thisProf.Stereotypes(p);
                        if~isempty(st.SuperClass)&&~isempty(st.SuperClass.ZCHandle)
                            st.ZCHandle.Parent=st.SuperClass.ZCHandle;
                        end
                    end
                end
            end
        end

        function applyStereotypes(this,elem)
            zcElem=elem.ZCHandle;

            for k=1:length(elem.StereotypesExtIDs)
                elemST=systemcomposer.xmi.CandidateElement.idMap(...
                "lookup",elem.StereotypesExtIDs(k));
                if~isempty(elemST)
                    zcElem.applyStereotype(...
                    char(elemST.Profile.FinalName+"."+elemST.Name));
                    elemST.trackAppliedElement(zcElem)
                    this.Stats.NumStereotypesApplied=...
                    this.Stats.NumStereotypesApplied+1;
                end
            end
            props=elem.StereotypePropVals;
            for p=1:length(props)
                propST=systemcomposer.xmi.CandidateElement.idMap(...
                "lookup",props(p).Stereotype);
                if~isempty(propST)
                    prop=propST.findProperty(props(p).PropertyName);
                    if~isempty(prop)
                        propName=propST.Profile.FinalName+"."+propST.Name+"."+prop.FinalName;
                        zcElem.setProperty(char(propName),...
                        ['''',props(p).Value,'''']);

                        this.Stats.NumStereotypePropsSet=...
                        this.Stats.NumStereotypePropsSet+1;
                    end
                end
            end
        end

        function createParameters(this,candArch)
            arch=candArch.ZCHandle;
            allPrmNames=[];
            for k=1:length(candArch.Parameters)
                thisPrm=candArch.Parameters(k);

                prmName=string(this.makeValidName(thisPrm.Name));
                allPrmNames=matlab.lang.makeUniqueStrings(...
                [allPrmNames,prmName],...
                [false(1,length(allPrmNames)),true],namelengthmax);
                prmName=allPrmNames(end);

                options={};
                if~strcmp(thisPrm.Dim,"1")
                    options{end+1}="Dimensions";%#ok
                    options{end+1}=thisPrm.Dim;%#ok
                end
                tName='double';
                if thisPrm.TypeName~=""
                    ptName=thisPrm.TypeName;
                    if contains(ptName,"Enumeration")
                        tName=['Enum:',char(thisElem.Type.BuildName)];
                    elseif contains(ptName,"Dtype:")
                        dtypeName=extractAfter(ptName,"Dtype:");
                        if isKey(this.DatatypeMapping,dtypeName)
                            tName=char(builder.DatatypeMapping(dtypeName));
                        else
                            if contains(dtypeName,'Bool','IgnoreCase',true)
                                tName='boolean';
                            elseif contains(dtypeName,'Int','IgnoreCase',true)||...
                                contains(dtypeName,'Natural','IgnoreCase',true)
                                tName='int32';
                            elseif contains(dtypeName,'Real','IgnoreCase',true)
                                tName='double';
                            elseif contains(dtypeName,'string','IgnoreCase',true)
                                tName='string';
                            end
                        end
                    end
                    options{end+1}="Type";%#ok
                    options{end+1}=string(tName);%#ok
                end
                if thisPrm.DefaultValue~=""
                    if string(tName)~="string"

                        try %#ok
                            eval(string(thisPrm.DefaultValue)+";");
                            options{end+1}="Value";%#ok
                            options{end+1}=thisPrm.DefaultValue;%#ok
                        end
                    else
                        options{end+1}="Value";%#ok
                        options{end+1}=thisPrm.DefaultValue;%#ok
                    end
                end
                if~isempty(options)
                    arch.addParameter(prmName,options{:});
                else
                    arch.addParameter(prmName);
                end
            end
        end

        function createRequirementsFile(this,candReqs)
            reqFileName=this.ProjectPath+filesep+...
            this.makeValidName(this.BuildProject)+"_REQ.slreqx";
            this.ReqFileName=reqFileName;

            this.ReqFile=slreq.new(reqFileName);
            this.RootProject.addFile(reqFileName);

            for k=1:length(candReqs)
                thisReq=candReqs{k};
                if isempty(thisReq.ParentRequirement)
                    this.recAddRequirementToSet(thisReq,...
                    this.ReqFile);
                end
            end
        end

        function createReqLinks(this,candReqLinks)

            allMdls=this.ArchModelExtIDMap.values;

            for k=1:length(allMdls)
                save_system(allMdls{k},'',...
                'SaveDirtyReferencedModels','on');
            end


            for k=1:length(candReqLinks)
                thisLink=candReqLinks{k};

                if~thisLink.Valid
                    continue;
                end

                supp=thisLink.Supplier;
                client=thisLink.Client;

                if isa(supp,'systemcomposer.xmi.CandidateRequirement')&&...
                    isa(client,'systemcomposer.xmi.CandidateRequirement')

                    lnk=slreq.createLink(supp.ZCHandle,client.ZCHandle);
                    if thisLink.LinkType=="SysML.DeriveReqt"
                        lnk.Type='Derive';
                    end

                    thisLink.ZCHandle=lnk;
                    this.Stats.NumReqLinks=this.Stats.NumReqLinks+1;
                elseif isa(supp,'systemcomposer.xmi.CandidateRequirement')
                    if~isempty(client.ZCHandle)
                        lnk=slreq.createLink(client.ZCHandle.SimulinkHandle,supp.ZCHandle);
                        lnk.Type='Implement';
                        this.Stats.NumReqLinks=this.Stats.NumReqLinks+1;
                    end
                elseif isa(client,'systemcomposer.xmi.CandidateRequirement')
                    if~isempty(supp.ZCHandle)
                        lnk=slreq.createLink(supp.ZCHandle.SimulinkHandle,client.ZCHandle);
                        lnk.Type='Implement';
                        this.Stats.NumReqLinks=this.Stats.NumReqLinks+1;
                    end
                else
                    if~isempty(client.ZCHandle)&&~isempty(supp.ZCHandle)
                        slreq.createLink(supp.ZCHandle.SimulinkHandle,...
                        client.ZCHandle.SimulinkHandle);
                    end
                end
            end


            this.AllLinkSets=[];

            ls=slreq.find('Type','LinkSet','Artifact',this.ReqFileName);
            if~isempty(ls)
                this.AllLinkSets=string(ls.Filename);
                ls.save;
            end

            for k=1:length(this.AllModelPaths)
                ls=slreq.find('Type','LinkSet','Artifact',this.AllModelPaths(k));
                if~isempty(ls)
                    this.AllLinkSets=[this.AllLinkSets,string(ls.Filename)];
                    ls.save;
                end
            end
        end

    end
end
