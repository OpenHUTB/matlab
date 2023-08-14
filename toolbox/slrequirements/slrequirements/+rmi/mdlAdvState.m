function result=mdlAdvState(action,value)
















    persistent word_state;
    persistent excel_state;
    persistent doors_state;
    persistent has_doors;%#ok<*PUSE>
    persistent has_word;
    persistent has_excel;

    if isempty(word_state)
        word_state=0;
    end
    if isempty(excel_state)
        excel_state=0;
    end
    if isempty(doors_state)
        doors_state=0;
    end

    result=0;

    switch action


    case 'word'
        if nargin==2
            word_state=value;
        else
            result=word_state;
        end
    case 'excel'
        if nargin==2
            excel_state=value;
        else
            result=excel_state;
        end
    case 'doors'
        if nargin==2
            doors_state=value;
        else
            result=doors_state;
        end


    case{'has_doors','has_word','has_excel'}
        if eval(['isempty(',action,')'])
            modelH=rmisl.getmodelh(value);
            [has_doors,has_word,has_excel]=rmi.probeReqs(modelH);
        end
        result=eval(action);


    case 'cleanup'
        try
            if word_state==1
                rmicom.wordRpt('destroy');
            end
            if excel_state==1
                rmicom.excelRpt('destroy');
            end

            word_state=0;
            excel_state=0;
            doors_state=0;
            has_doors=[];
            has_word=[];
            has_excel=[];
            result=1;
        catch Mex %#ok
            result=0;
        end
    end

