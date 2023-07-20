function loadHierarchy(this,progressBarInfo)




    prevViewMode=ensureNormalView(this);

    comParagraphs=this.hDoc.Paragraphs;
    paraCnt=comParagraphs.Count;

    this.iLevels=zeros(1,paraCnt);
    this.iParents=-1*ones(1,paraCnt);
    this.iStarts=zeros(1,paraCnt);
    this.iEnds=zeros(1,paraCnt);

    current_header_idx=-1;

    for i=1:paraCnt
        parag=comParagraphs.Item(i);
        this.iStarts(i)=parag.Range.Start;
        this.iEnds(i)=parag.Range.End;


        level=get_header_level(parag);
        this.iLevels(i)=level;
        if level<0
            if current_header_idx<0

                this.iLevels(i)=1;
            else

                this.iParents(i)=current_header_idx;
            end

        else

            if current_header_idx>0
                this.iParents(i)=find_parent(this.iLevels(1:i));
            end

            current_header_idx=i;

        end


        if~isempty(progressBarInfo)&&mod(i,50)==0
            if rmiut.progressBarFcn('isCanceled')
                break;
            else
                rmiut.progressBarFcn('set',progressBarInfo(1)+(i/paraCnt)*progressBarInfo(2),...
                getString(message('Slvnv:reqmgt:linktype_rmi_word:GeneratingDocumentIndex')));
            end
        end
    end



    if~isempty(prevViewMode)
        restoreViewMode(this,prevViewMode);
    end

end




































































function parent_idx=find_parent(myLevels)
    myLevel=myLevels(end);
    prevLevels=myLevels(1:end-1);
    couldBeMyHeader=find(prevLevels>0&prevLevels<myLevel);
    if isempty(couldBeMyHeader)
        parent_idx=-1;
    else
        parent_idx=couldBeMyHeader(end);
    end
end

function level=get_header_level(paragraph)
    outlineLevel=paragraph.OutlineLevel;
    if strcmp(outlineLevel,'wdOutlineLevelBodyText')
        level=-1;
    else
        level=sscanf(outlineLevel,'wdOutlineLevel%d');
    end
end


function restoreViewMode(this,prevViewMode)
    if strcmp(prevViewMode,'wdMasterView')
        this.hDoc.ActiveWindow.Selection.Collapse(0);
    end
    this.hDoc.ActiveWindow.View.Type=prevViewMode;
end

function prevViewMode=ensureNormalView(this)
    if~strcmp(this.hDoc.ActiveWindow.View.Type,'wdNormalView')
        prevViewMode=this.hDoc.ActiveWindow.View.Type;
        this.hDoc.ActiveWindow.View.Type='wdNormalView';
    else
        prevViewMode='';
    end
end

