function tf=acceptDrop(this,dropObjects)




    tf=false;


    if isempty(dropObjects)
        return;
    end

    for i=1:length(dropObjects)
        if isa(dropObjects(i),'RptgenML.LibraryRpt')
            tf=true;

            lastRpt=this.addReport(fullfile(dropObjects(i).PathName,...
            dropObjects(i).FileName));
        elseif~isequal(up(dropObjects(i)),this)
            connect(dropObjects(i),this,'up');
        end
    end

