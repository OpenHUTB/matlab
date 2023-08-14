classdef CloneGroups<handle










    properties
        clonesColumnContent;
        children;
        parent;
        edit;
        m2mObj;
        numClones;
        numBlocksPerClone;
        numBlockDiff;
        numParamDiff;
        cloneGroupIndex;
        newLibraryPath;
        differentBlockIndex;
        paramDiffHtml='';
        ddgRightObj;

        clonegroupId;
        numCloneCandidates;
        maxPlotLength;
        rgbArray;
        paramDiff;

        cloneGroupsSSColumn1=DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn1');
        cloneGroupsSSColumn2=DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn2');
        cloneGroupsSSColumn3=DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn3');
        cloneGroupsSSColumn4=DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn4');
        cloneGroupsSSColumn5=DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn5');
        cloneGroupsSSColumn6=DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn6');
        cloneGroupsSSColumn8=DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn8');
        cloneGroupsSSColumn9=DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn9');
    end
    methods(Access=public)


        function this=CloneGroups(ddgRightObj,m2mObj,edit,clonesColumnContent,...
            children,numClones,numBlocksPerClone,numBlockDiff,...
            numParamDiff,cloneGroupIndex,differentBlockIndex)
            if(nargin>0)
                this.clonesColumnContent=clonesColumnContent;
                this.children=children;
                this.edit=edit;
                this.m2mObj=m2mObj;
                this.numBlockDiff=numBlockDiff;
                this.numBlocksPerClone=numBlocksPerClone;
                this.numClones=numClones;
                this.numParamDiff=numParamDiff;
                this.cloneGroupIndex=cloneGroupIndex;
                this.newLibraryPath='';
                this.differentBlockIndex=differentBlockIndex;

                this.ddgRightObj=ddgRightObj;

                if isprop(this.m2mObj,'isReplaceExactCloneWithSubsysRef')
                    if(~isempty(this.cloneGroupIndex))&&this.m2mObj.isReplaceExactCloneWithSubsysRef
                        idx=this.m2mObj.cloneresult.exact{this.cloneGroupIndex}.index;
                        name=slEnginePir.CloneRefactor.get_subsysref_name(this.m2mObj,this.m2mObj.cloneresult.Before{idx},idx);
                        this.m2mObj.cloneresult.exact{this.cloneGroupIndex}.targetLib=name;
                    end
                end

            end
        end

        function setCloneComparisonProperties(this,clonegroupId,numCloneCandidates,...
            maxPlotLength,rgbArray,paramDiff)

            this.clonegroupId=clonegroupId;
            this.numCloneCandidates=numCloneCandidates;
            this.maxPlotLength=maxPlotLength;
            this.rgbArray=rgbArray;
            this.paramDiff=paramDiff;
        end

        function label=getDisplayLabel(this)
            label=this.clonesColumnContent;
        end


        function fileName=getDisplayIcon(~)
            fileName='hidinghierarchyIcon.png';
        end


        function propValue=getPropValue(this,propName)
            switch propName
            case this.cloneGroupsSSColumn2
                propValue=this.clonesColumnContent;
            case this.cloneGroupsSSColumn1
                if~isempty(this.children)
                    propValue=' ';
                else
                    propValue=this.edit;
                end
            case this.cloneGroupsSSColumn6
                if isempty(this.children)
                    propValue=' ';
                else
                    if strcmp(this.numBlockDiff,'0')
                        this.newLibraryPath=this.m2mObj.cloneresult.exact{this.cloneGroupIndex}.targetLib;
                    elseif~isempty(this.numBlockDiff)
                        this.newLibraryPath=this.m2mObj.cloneresult.similar{this.cloneGroupIndex}.targetLib;
                    else
                        this.newLibraryPath=this.m2mObj.cloneresult.librarymap{this.cloneGroupIndex}.targetLib;
                    end
                    propValue=this.newLibraryPath;
                end
            case this.cloneGroupsSSColumn3
                if isempty(this.children)
                    propValue=' ';
                else
                    propValue=this.numBlocksPerClone;
                end
            case this.cloneGroupsSSColumn4
                if isempty(this.children)
                    if strcmp(this.numParamDiff,'0')
                        propValue='';
                    elseif~isempty(this.numParamDiff)
                        if this.m2mObj.enableClonesAnywhere
                            this.paramDiffHtml=this.populateParamDiffForClonesAnywhere(this.m2mObj,...
                            this.m2mObj.creator.clonegroups(this.parent.cloneGroupIndex).Region(this.cloneGroupIndex),this.differentBlockIndex);
                        else
                            this.paramDiffHtml=this.populateParamDiff(this.m2mObj,...
                            this.clonesColumnContent,this.differentBlockIndex);
                        end

                        if strcmp(this.paramDiffHtml,'Baseline')
                            propValue=DAStudio.message('sl_pir_cpp:creator:BaselineCloneTitle');
                        else
                            propValue=DAStudio.message('sl_pir_cpp:creator:ViewParameterDifferenceInProperties');
                        end
                    else
                        propValue='';
                    end
                else
                    propValue=this.numBlockDiff;
                end
            case this.cloneGroupsSSColumn5
                if isempty(this.children)
                    propValue=' ';
                else
                    propValue=this.numParamDiff;
                end
            case this.cloneGroupsSSColumn8
                propValue='';
            case this.cloneGroupsSSColumn9
                propValue=this.numClones;
            otherwise
                propValue='';
            end
        end




        function[bIsReadOnly]=isReadonlyProperty(this,aPropName)
            switch(aPropName)
            case this.cloneGroupsSSColumn6
                bIsReadOnly=true;



                if isprop(this.m2mObj,'isReplaceExactCloneWithSubsysRef')
                    if(~isempty(this.cloneGroupIndex))&&this.m2mObj.isReplaceExactCloneWithSubsysRef
                        bIsReadOnly=false;
                        idx=this.m2mObj.cloneresult.exact{this.cloneGroupIndex}.index;
                        name=slEnginePir.util.SubsystemRef.checkReferencedSubsystem(this.m2mObj.cloneresult.Before{idx});
                        if(~isempty(name))
                            bIsReadOnly=true;
                        end
                    end
                end

            case this.cloneGroupsSSColumn1
                if~isempty(this.children)
                    bIsReadOnly=true;
                else
                    bIsReadOnly=false;
                end
            otherwise
                bIsReadOnly=true;
            end
        end




        function setPropValue(this,prop,newVal)
            switch(prop)
            case this.cloneGroupsSSColumn1
                if strcmp(newVal,'1')
                    this.edit='1';
                    CloneDetectionUI.internal.util.m2m_toggle_sysclone...
                    (this.m2mObj,this.clonesColumnContent,1);
                else
                    this.edit='0';
                    CloneDetectionUI.internal.util.m2m_toggle_sysclone...
                    (this.m2mObj,this.clonesColumnContent,0);
                end

                if needMetricsUpdate(this,newVal)
                    metrics=this.ddgRightObj.cloneUIObj.metrics;
                    isExact=strcmp(this.numParamDiff,'0');
                    this.ddgRightObj.cloneUIObj.metrics=...
                    CloneDetectionUI.internal.util.updateMetrics...
                    (metrics,str2double(this.edit),str2double(this.numBlocksPerClone),isExact);
                end
                dlg=DAStudio.ToolRoot.getOpenDialogs(this.ddgRightObj);
                dlg.refresh;


                this.saveCloneDetectionUIObj;
            case this.cloneGroupsSSColumn6
                if strcmp(this.numBlockDiff,'0')
                    this.m2mObj.cloneresult.exact{this.cloneGroupIndex}.targetLib=newVal;
                else
                    this.m2mObj.cloneresult.similar{this.cloneGroupIndex}.targetLib=newVal;
                end
                this.newLibraryPath=newVal;

                this.saveCloneDetectionUIObj;

            end
        end



        function aPropType=getPropDataType(this,aPropName)
            switch(aPropName)
            case this.cloneGroupsSSColumn1
                if~isempty(this.children)
                    aPropType='string';
                else
                    aPropType='bool';
                end
            otherwise
                aPropType='string';
            end
        end


        function getPropertyStyle(this,aPropName,propertyStyle)
            switch(aPropName)
            case this.cloneGroupsSSColumn8
                if~isempty(this.children)
                    if~isempty(this.rgbArray)
                        if this.numCloneCandidates>100
                            plotLength=100;
                            maxLength=100;
                        else
                            plotLength=this.numCloneCandidates;
                            maxLength=this.maxPlotLength;
                        end

                        propertyStyle.WidgetInfo=struct('Type','progressbar',...
                        'Values',[plotLength,maxLength-plotLength],'Colors',...
                        [[this.rgbArray{1},this.rgbArray{2},this.rgbArray{3},1],[1,1,1,1]]);
                        propertyStyle.Tooltip=this.paramDiff;
                    end
                end
            otherwise
                if~isempty(this.children)
                    aStyle=propertyStyle;
                    aStyle.Bold=true;
                end
            end
        end


        function isHier=isHierarchical(~)
            isHier=true;
        end

        function children=getChildren(this)
            children=this.children;
        end

        function children=getHierarchicalChildren(this)
            children=this.children;
        end


        function isValid=isValidProperty(this,propName)

            switch propName
            case this.cloneGroupsSSColumn1
                isValid=true;
            case this.cloneGroupsSSColumn2
                isValid=true;
            case this.cloneGroupsSSColumn3
                isValid=true;
            case this.cloneGroupsSSColumn4
                isValid=true;
            case this.cloneGroupsSSColumn5
                isValid=true;
            case this.cloneGroupsSSColumn6
                isValid=true;
            case this.cloneGroupsSSColumn8
                isValid=true;
            case this.cloneGroupsSSColumn9
                isValid=true;
            otherwise
                isValid=false;
            end
        end


    end

    methods(Access=private)

        function saveCloneDetectionUIObj(this)

            cloneUIObj=get_param(this.ddgRightObj.model,'CloneDetectionUIObj');
            if~exist(cloneUIObj.backUpPath,'dir')
                mkdir(cloneUIObj.backUpPath);
                cloneUIObj.historyVersions=[];
            end
            updatedObj=cloneUIObj;
            save(cloneUIObj.objectFile,'updatedObj');
        end



        function entry=populateParamDiff(this,m2mObj,fname,differentIndex)


            entry='<div style="overflow-x:auto;font-size:0.75em"><table>';
            diffbp=m2mObj.creator.differentBlockParamName;

            for i=1:length(differentIndex)
                ind=differentIndex(i);
                baselineblocks=diffbp(ind).Block;
                baselineblocks=strrep(baselineblocks,newline,' ');
                if this.isParent(fname,getfullname(baselineblocks))
                    entry='Baseline';
                    return;
                end
            end

            blockdiffFlag=true;
            for i=1:length(differentIndex)
                ind=differentIndex(i);
                for j=1:length(diffbp(ind).MappedBlocks)
                    mappedblocks=diffbp(ind).MappedBlocks{j};
                    mappedblocks=strrep(mappedblocks,newline,' ');
                    if this.isParent(fname,getfullname(mappedblocks))

                        blockNameStr=['<tr><td>',int2str(i),...
                        '.</td><td>&nbsp <a href="matlab: Simulink.ID.hilite(''',Simulink.ID.getSID(mappedblocks),...
                        ''')">',mappedblocks,'</a><br/><b> Parameters: </b>'];
                        entry=strcat(entry,blockNameStr);

                        len=length(diffbp(ind).ParameterNames);
                        for k=1:len
                            paramStr=['<a href="matlab:Simulink.internal.OpenBlockParamsDialog'...
                            ,'(''',mappedblocks,''',''',diffbp(ind).ParameterNames{k},''')">'...
                            ,diffbp(ind).ParameterNames{k},...
                            '</a> &nbsp &nbsp'];
                            entry=strcat(entry,paramStr);
                        end
                        entry=strcat(entry,'</td></tr>');
                        blockdiffFlag=false;
                        break;
                    end
                end
            end

            if blockdiffFlag
                entry='0 block difference';
                return;
            end

            entry=strcat(entry,'</table></div>');
        end


        function entry=populateParamDiffForClonesAnywhere(this,m2mObj,fname,differentIndex)


            entry='<div style="overflow-x:auto;font-size:0.75em"><table>';
            diffbp=m2mObj.creator.differentBlockParamName;

            for i=1:length(differentIndex)
                ind=differentIndex(i);
                if(ind~=0)
                    for j=1:length(fname.Candidates)
                        baselineblocks=diffbp(ind).Block;
                        baselineblocks=strrep(baselineblocks,newline,' ');
                        if this.isParent(fname.Candidates{j},getfullname(baselineblocks))||...
                            strcmp(fname.Candidates{j},getfullname(baselineblocks))
                            entry='Baseline';
                            return;
                        end
                    end
                end
            end

            blockdiffFlag=true;
            addedBlocks=containers.Map('KeyType','char','ValueType','double');
            diffIdx=1;
            for i=1:length(differentIndex)
                ind=differentIndex(i);
                if(ind~=0)
                    for j=1:length(diffbp(ind).MappedBlocks)
                        for k=1:length(fname.Candidates)
                            mappedblocks=diffbp(ind).MappedBlocks{j};
                            mappedblocks=strrep(mappedblocks,newline,' ');
                            if(this.isParent(fname.Candidates{k},getfullname(mappedblocks))||...
                                strcmp(fname.Candidates{k},getfullname(mappedblocks)))&&...
                                ~isKey(addedBlocks,mappedblocks)
                                blockNameStr=['<tr><td>',int2str(diffIdx),...
                                '.</td><td>&nbsp <a href="matlab: Simulink.ID.hilite(''',Simulink.ID.getSID(mappedblocks),...
                                ''')">',mappedblocks,'</a><br/><b> Parameters: </b>'];
                                entry=strcat(entry,blockNameStr);
                                addedBlocks(mappedblocks)=1;
                                diffIdx=diffIdx+1;

                                len=length(diffbp(ind).ParameterNames);
                                for l=1:len
                                    paramStr=['<a href="matlab:Simulink.internal.OpenBlockParamsDialog'...
                                    ,'(''',mappedblocks,''',''',diffbp(ind).ParameterNames{l},''')">'...
                                    ,diffbp(ind).ParameterNames{l},...
                                    '</a> &nbsp &nbsp'];
                                    entry=strcat(entry,paramStr);
                                end
                                entry=strcat(entry,'</td></tr>');
                                blockdiffFlag=false;
                                break;
                            end
                        end
                    end
                end
            end

            if blockdiffFlag
                entry='0 block difference';
                return;
            end

            entry=strcat(entry,'</table></div>');
        end



        function flag=isParent(~,pstr,cstr)
            flag=true;
            pstrC=textscan(pstr,'%s','Delimiter','/');
            cstrC=textscan(cstr,'%s','Delimiter','/');

            if length(pstrC{1})>length(cstrC{1})
                flag=false;
                return;
            end
            for i=1:length(pstrC{1})
                if~strcmp(pstrC{1}{i},cstrC{1}{i})
                    flag=false;
                    return;
                end
            end
        end
    end

    methods(Static)
        function selected=selectCloneRowCallback(tag,selectedRowAsCell,dlg)
            selected=false;
            this=selectedRowAsCell{1};
            if isempty(this)||~isa(this,'CloneDetectionUI.internal.SpreadSheetItem.CloneGroups')
                return;
            end



            CloneDetectionUI.internal.util.removeAllHighlights;

            allSys=find_system('SearchDepth',0);
            for ii=1:length(allSys)
                set_param(allSys{ii},'HiliteAncestors','off');
                set_param(allSys{ii},'HiliteAncestors','fade');
            end


            stylerName='CloneDetection.styleAllClones';
            styler=diagram.style.getStyler(stylerName);
            if(isempty(styler))
                diagram.style.createStyler(stylerName);
                styler=diagram.style.getStyler(stylerName);
            end


            styleName='hiliteStyle';
            if strcmp(this.numParamDiff,'0')
                highlightColor=CloneDetectionUI.internal.util.getExactColorCode;


                exactColor=CloneDetectionUI.internal.util.getExactColorCodeNumerical;
                exactstyle=diagram.style.Style;
                exactstyle.set('FillStyle','Solid');
                exactstyle.set('FillColor',[exactColor,1.0]);
                exactstyle.set('TextColor',[exactColor,1.0]);

                exactTagRule=styler.addRule(exactstyle,diagram.style.ClassSelector(styleName));

            elseif~isempty(this.numParamDiff)
                str=this.clonesColumnContent;
                if~contains(str,'Similar')
                    str=this.parent.clonesColumnContent;
                end
                if contains(str,'Similar')
                    str=textscan(str,'%s','Delimiter',' ');

                    similarCount=length(this.m2mObj.cloneresult.similar);

                    darkest=CloneDetectionUI.internal.util.getSimilarColorCodeNumerical;
                    lightest=CloneDetectionUI.internal.util.getSimilarLightColorCodeNumerical;
                    red=linspace(lightest(1),darkest(1),similarCount+1);
                    green=linspace(lightest(2),darkest(2),similarCount+1);
                    blue=linspace(lightest(3),darkest(3),similarCount+1);

                    i=str2num(str{1}{end});

                    similarColor=[red(similarCount-i+1),green(similarCount-i+1),blue(similarCount-i+1)];
                    if~isempty(similarColor)
                        similarstyle=diagram.style.Style;
                        similarstyle.set('FillStyle','Solid');
                        similarstyle.set('FillColor',[similarColor,1.0]);
                        similarstyle.set('TextColor',[similarColor,1.0]);
                        similarTagRule(i)=styler.addRule(similarstyle,diagram.style.ClassSelector(styleName));
                    end
                end
                highlightColor=CloneDetectionUI.internal.util.getSimilarColorCode;
            else
                highlightColor=CloneDetectionUI.internal.util.getSimilarColorCode;
            end

            set_param(0,'HiliteAncestorsData',...
            struct('HiliteType','user2',...
            'ForegroundColor','black',...
            'BackgroundColor',highlightColor));
            if~isempty(this.children)


                if strncmp(this.children(1).clonesColumnContent,'Clone Region',12)

                    hilite_system(this.clonesColumnContent,'user2');
                else
                    for i=1:length(this.children)
                        styler.applyClass(this.children(i).clonesColumnContent,styleName);

                    end
                end
            else

                if~strncmp(this.clonesColumnContent,'Clone Region',12)
                    styler.applyClass(this.clonesColumnContent,styleName);

                else
                    ind=this.cloneGroupIndex;

                    if isfield(this.m2mObj.cloneresult.Before,'Region')
                        parentIndex=this.parent.cloneGroupIndex;
                        allblocks=this.m2mObj.cloneresult.Before(parentIndex).Region(ind).Candidates;
                    else
                        allblocks=this.m2mObj.cloneresult.Before.mdlBlks{ind};
                    end
                    for k=1:length(allblocks)

                        hilite_system(allblocks{k},'user2');
                    end
                end
            end



            this.ddgRightObj.blockdiffHtml=this.paramDiffHtml;
            CloneDetectionUI.internal.util.showEmbedded(this.ddgRightObj,'Right','Tabbed');
            dlg=DAStudio.ToolRoot.getOpenDialogs(this.ddgRightObj);
            dlg.refresh;

            selected=true;
        end
    end
end

function boolResult=needMetricsUpdate(thisCloneGroup,newVal)




    boolResult=true;
    children=thisCloneGroup.parent.children;
    n=length(children);
    numOfChecked=0;

    for i=1:n
        if children(i).edit=='1'
            numOfChecked=numOfChecked+1;
            if numOfChecked>=2
                return;
            end
        end
    end

    if(strcmp(newVal,'1')&&numOfChecked<2)||(strcmp(newVal,'0')&&numOfChecked<1)
        boolResult=false;
    end

end




