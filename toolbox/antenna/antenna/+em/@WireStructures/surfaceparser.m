function[parseobj]=surfaceparser(obj,inputdata,funName)%#ok<INUSL>




    if isempty(inputdata)
        updatedipdata{1}='scale';
        updatedipdata{2}='linear';
        updatedipdata{3}='Slicer';
        updatedipdata{4}='off';



    else
        updatedipdata=inputdata;
    end


    parseobj=inputParser;
    parseobj.FunctionName=funName;
    expectedscale={'linear','log','log10'};
    expectedoption={'on','off'};







    sc=[];sc_indx=[];
    for i=1:size(updatedipdata,2)
        sc(i)=strcmpi(updatedipdata{i},'scale');
    end
    if~isempty(sc)
        sc_indx=find(sc,1);
    end
    if~isempty(sc_indx)
        if(size(updatedipdata,2)==sc_indx)

            updatedipdata{sc_indx+1}='linear';
            addParameter(parseobj,'scale','linear',@(x)any(validatestring(x,expectedscale)));
        elseif isa(updatedipdata{sc_indx+1},'function_handle')

            addParameter(parseobj,'scale',updatedipdata{sc_indx+1});
        else

            addParameter(parseobj,'scale','linear',@(x)any(validatestring(x,expectedscale)));
        end
    else

        addParameter(parseobj,'scale','linear',@(x)any(validatestring(x,expectedscale)));
    end

    slicertypeValidationFcn=@(x)any(validatestring(x,expectedoption));
    sl=[];sl_indx=[];
    for i=1:size(updatedipdata,2)
        sl(i)=strcmpi(updatedipdata{i},'Slicer');
    end
    if~isempty(sl)
        sl_indx=find(sl,1);
    end
    if~isempty(sl_indx)
        if(size(updatedipdata,2)==sl_indx)

            updatedipdata{sl_indx+1}='off';
        end
        if~isa(updatedipdata{sl_indx+1},'char')&&~isa(updatedipdata{sl_indx+1},'string')

            slicertypeValidationFcn=@(x)validateattributes(x,{'logical',...
            'double'},{'nonempty','scalar','real','nonnan','finite','binary'});
        end
    end
    addParameter(parseobj,'Slicer','off',slicertypeValidationFcn);

    parse(parseobj,updatedipdata{:});