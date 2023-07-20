function out=execute(c,d,varargin)




    if isempty(c.RuntimeLoopObjects)
        c.RuntimeLoopObjects=c.loop_getLoopObjects;
    end

    try
        ps=c.loop_getPropSrc;
    catch Mex %#ok<NASGU>
        ps=[];
        c.status(getString(message('Sldv:RptSldv:Iterator:execute:CouldNotLocatePropertySource')),1);
    end

    if isempty(c.RuntimeLoopObjects)
        out=[];
        try
            c.status(sprintf('%s',getString(message('Sldv:RptSldv:Iterator:execute:NoObjectsFoundLooping',lower(c.loop_getObjectType([],ps))))),4);
        catch Mex %#ok<NASGU>

            c.status(getString(message('Sldv:RptSldv:Iterator:execute:NoObjectsFoundLooping_1')),4);
        end
        return;
    elseif ischar(c.RuntimeLoopObjects)
        c.RuntimeLoopObjects={c.RuntimeLoopObjects};
        subsrefType='{}';
    elseif iscell(c.RuntimeLoopObjects)
        subsrefType='{}';
    else
        subsrefType='()';
    end

    try
        oldState=c.loop_saveState;
    catch Mex
        oldState=[];
        c.status(Mex.message,1);
    end

    r=rptgen.appdata_rg;
    out=createDocumentFragment(d);

    oldRST=c.RuntimeSectionType;
    if c.ObjectSection
        c.RuntimeSectionType=c.getSectionType;
    else
        c.RuntimeSectionType='ignore';
    end







    for i=1:size(c.RuntimeLoopObjects,1)
        if r.HaltGenerate
            status(c,sprintf('%s',getString(message('Sldv:RptSldv:Iterator:execute:LoopExecutionHalted',c.loop_getObjectType([],ps)))),2);
            break
        end

        loopObject=subsref(c.RuntimeLoopObjects,substruct(subsrefType,{i,':'}));
        c.RuntimeCurrentObject=loopObject;





        try
            objectName=c.loop_getObjectName(loopObject,ps);
        catch Mex %#ok<NASGU>
            objectName=rptgen.toString(loopObject);

        end

        try
            ok=c.loop_setState(loopObject,objectName);
        catch Mex %#ok<NASGU>
            ok=false;
        end

        if ok
            try
                objectType=c.loop_getObjectType(loopObject,ps);
            catch Mex %#ok<NASGU>
                objectType=getString(message('Sldv:RptSldv:Iterator:execute:UnknownType'));

            end

            status(c,sprintf('%s',getString(message('Sldv:RptSldv:Iterator:execute:LoopingOn',lower(objectType),objectName))),3);

            c.loop_makeSection(d);

            if c.ObjectSection
                sectionTitle=c.getSectionTitle(loopObject);

                if isempty(sectionTitle)
                    sectionTitle=objectName;
                end
                if c.ShowTypeInTitle %#ok
                    sectionTitle=d.createDocumentFragment(objectType,' - ',sectionTitle);
                end
                if c.ObjectAnchor

                    sectionTitle=d.createDocumentFragment(...
                    makeAnchor(c,d,loopObject,objectType,ps),...
                    sectionTitle);
                end
                c.addTitle(d,sectionTitle);
            else
                if c.ObjectAnchor
                    c.RuntimeSerializer.write(makeAnchor(c,d,loopObject,objectType,ps));
                end
            end

            c.writeChildren(d);
            thisOut=c.loop_closeSection;
            if~isempty(thisOut)
                out.appendChild(thisOut);
            end
        else
            c.status(sprintf('%s',getString(message('Sldv:RptSldv:Iterator:execute:IsNotA',objectName))),2);
        end
    end

    try


        c.loop_restoreState(oldState);
    catch Mex
        c.status(Mex.message,1);
    end

    c.RuntimeSectionType=oldRST;
    c.RuntimeLoopObjects=[];
    c.RuntimeCurrentObject=[];


    function anchorElement=makeAnchor(c,d,loopObject,objectType,ps)

        try
            anchorID=c.loop_getObjectLinkID(loopObject,objectType,ps);
        catch Mex
            anchorElement=d.createDocumentFragment;
            c.status(getString(message('Sldv:RptSldv:Iterator:execute:UnableCreateLinkingAnchor')),2);
            c.status(Mex.message,5);
            return;
        end

        anchorElement=d.makeLink(anchorID,'','anchor');

