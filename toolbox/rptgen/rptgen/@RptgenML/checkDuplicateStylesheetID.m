function dupeFound=checkDuplicateStylesheetID(this,idVal)












    if nargin<2

        try
            idVal=this.ID;
        catch


            dupeFound=false;
            return;
        end
        this=up(this);
    end

    if isempty(this)
        dupeFound=false;
        return;
    end

    duplicateHandles=find(this,'-depth',1,'-isa','rptgen.DAObject','ID',idVal);
    switch length(duplicateHandles)
    case 0
        dupeFound=false;
    case 1
        dupeFound=false;
        set(duplicateHandles,'ErrorMessage','');
        duplicateHandles.updateErrorState;
    otherwise
        dupeFound=true;
        set(duplicateHandles,'ErrorMessage',...
        getString(message('rptgen:RptgenML:duplicateStylesheetIDMsg',...
        idVal,idVal)));
    end

    ed=DAStudio.EventDispatcher;
    for i=1:length(duplicateHandles)
        ed.broadcastEvent('PropertyChangedEvent',duplicateHandles(i));

    end

