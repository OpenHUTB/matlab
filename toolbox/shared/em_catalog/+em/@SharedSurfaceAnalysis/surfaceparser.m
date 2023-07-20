function[parseobj]=surfaceparser(obj,inputdata,funName)%#ok<INUSL>















































    if isempty(inputdata)
        updatedipdata{1}='region';
        updatedipdata{2}='metal';
        updatedipdata{3}='scale';
        updatedipdata{4}='linear';
        updatedipdata{5}='Slicer';
        updatedipdata{6}='off';
        if isa(obj,'rfpcb.PrintedLine')||isa(obj,'pcbComponent')
            N=getNumFeedLocations(obj);
            updatedipdata{7}='excitation';
            updatedipdata{8}=voltagePort(N);
            updatedipdata{9}='Type';
            updatedipdata{10}='absolute';
            updatedipdata{11}='Direction';
            updatedipdata{12}='off';
        else
            updatedipdata{7}='Type';
            updatedipdata{8}='absolute';
            updatedipdata{9}='Direction';
            updatedipdata{10}='off';
        end
    else

        indx=find(strcmpi(inputdata{1},{'metal'}));
        if isempty(indx)
            indx=find(strcmpi(inputdata{1},{'dielectric'}));
        end
        if~isempty(indx)
            n=numel(inputdata);
            if indx>1&&indx<n
                updatedipdata=[inputdata(1:indx-1),'region',inputdata(indx:end)];
            elseif indx==1
                updatedipdata=['region',inputdata];
            elseif indx==n
                updatedipdata=[inputdata(1:n-1),'region',inputdata(n)];
            end
        else
            updatedipdata=inputdata;
        end
    end


    parseobj=inputParser;
    parseobj.FunctionName=funName;
    expectedregion={'metal','dielectric'};
    expectedscale={'linear','log','log10'};
    expectedoption={'on','off'};
    expectedtype={'real','imaginary','absolute'};
    expecteddirection={'on','off'};

    addParameter(parseobj,'region','metal',@(x)any(validatestring(x,expectedregion)));
    addParameter(parseobj,'Type','absolute',@(x)any(validatestring(x,expectedtype)));
    addParameter(parseobj,'Direction','off',@(x)any(validatestring(x,expecteddirection)));
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

    if isa(obj,'rfpcb.PrintedLine')||isa(obj,'pcbComponent')
        N=getNumFeedLocations(obj);
        addParameter(parseobj,'excitation',voltagePort(N),@(x)isa(x,'voltagePort'));
    end

    parse(parseobj,updatedipdata{:});