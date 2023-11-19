function cacheData=simrfV2_process_rational_model(block,MaskWSValues)...

    if isfield(MaskWSValues,'isRationalObj')&&...
        strcmp(MaskWSValues.isRationalObj,'on')
        ratObj=MaskWSValues.RationalObject;
        if isa(ratObj,'rational')
            if isempty(ratObj)
                error(message('simrf:simrfV2errors:BadObject',...
                'rational',get_param(block,'RationalObject')))
            end
            validateattributes(ratObj,{'rational'},{'nonempty'},'',class(ratObj))
            numPorts=ratObj.NumPorts;
            Poles=cell(numPorts^2,1);
            Residues=Poles;
            DF=Poles;
            sz=[numPorts,numPorts];
            for col_idx=1:numPorts
                for row_idx=1:numPorts
                    lin_idx=sub2ind(sz,row_idx,col_idx);
                    Poles(lin_idx)=num2cell(ratObj.Poles,1);
                    Residues(lin_idx)={squeeze(ratObj.Residues(row_idx,col_idx,:))};
                    DF(lin_idx)={ratObj.DirectTerm(row_idx,col_idx)};
                end
            end
        elseif isa(ratObj,'rfmodel.rational')
            if isempty(ratObj)
                error(message('simrf:simrfV2errors:BadObject',...
                'rfmodel.rational',get_param(block,'RationalObject')))
            end
            validateattributes(ratObj,{'rfmodel.rational'},...
            {'nonempty','square'},'',class(ratObj))
            numPorts=size(ratObj,1);
            Poles=cell(numPorts^2,1);
            Residues=Poles;
            DF=Poles;
            sz=[numPorts,numPorts];
            for col_idx=1:numPorts
                for row_idx=1:numPorts
                    lin_idx=sub2ind(sz,row_idx,col_idx);
                    Poles(lin_idx)=num2cell(ratObj(row_idx,col_idx).A,1);
                    Residues(lin_idx)=num2cell(ratObj(row_idx,col_idx).C,1);
                    DF(lin_idx)={ratObj(row_idx,col_idx).D};
                end
            end
            if any([ratObj(:).Delay]~=0)
                error(message('simrf:simrfV2errors:NoDelayAllowed',...
                'rfmodel.rational',get_param(block,'RationalObject')))
            end
        end
    else

        Poles=MaskWSValues.Poles(:);
        Residues=MaskWSValues.Residues(:);
        DF=MaskWSValues.DF(:);
    end


    auxData=simrfV2_getauxdata(block);
    cacheData=simrfV2_getcachedata(block);
    if~iscell(DF)
        DFmat=DF;
        DF=num2cell(DF);
    else
        DFmat=cell2mat(DF);
    end
    DFmat=reshape(DFmat,sqrt(size(DF,1)),[]);


    if strcmpi(get_param(block,'ClassName'),'amplifier')
        portSizes=[2,2];
    else
        portSizes=[1,65];
    end


    if isempty(Poles)||isempty(Residues)||...
        isequal(Poles,0)||isequal(Residues,0)
        nports=sqrt(size(DF,1));
        validateattributes(nports,{'numeric'},...
        {'scalar','integer','>=',portSizes(1),'<=',portSizes(2)},...
        mfilename,'Number of ports')
        if any(any(cellfun(@isempty,DF)))
            error(message('simrf:simrfV2errors:DataNotSquare','DF'))
        end
        validateattributes(DFmat,{'numeric'},{'real','finite'},mfilename,'DF')
        cacheData.RationalModel.A={};
        cacheData.RationalModel.C={};
        cacheData.RationalModel.D=DF(:);
        cacheData.RationalModel.ACell={};
        cacheData.RationalModel.CCell={};
        [~,~,Dname_cell]=get_rational_param_names(1);
        DF_real=reshape(DFmat.',1,[]);

        D=[Dname_cell;{simrfV2vector2str(DF_real)}];
        cacheData.RationalModel.DCell=D;
        cacheData.RationalModel.Z0Cell={'Z0';...
        simrfV2vector2str(50*ones(1,nports))};
        cacheData.filename=[];
        cacheData.hashcode=0;
        cacheData.timestamp=[];
        cacheData.Impedance=50;
        cacheData.NumPorts=nports;
        auxData.Spars.NumPorts=nports;
        auxData.Spars.Impedance=50;
        auxData.Spars.Parameters=DFmat;
        auxData.Spars.Frequencies=1e9;
        set_param(block,'UserData',cacheData)
        set_param([block,'/AuxData'],'UserData',auxData);

        return
    end



    if~iscell(Poles)||~iscell(Residues)||~iscell(DF)||...
        ~(isequal(size(Poles),size(Residues))||...
        (isequal(size(Poles,2),size(Residues,2))&&...
        size(Poles,1)==1)||isequal(size(Poles),[1,1]))...
        ||~isequal(size(Residues),size(DF))
        error(message('simrf:simrfV2errors:IncorrectPoleCellSize'))
    end

    validateattributes(cellfun(@(x)length(x),Poles),{'numeric'},...
    {'<=',99},'','Number of poles')
    validateattributes(cellfun(@(x)length(x),Residues),{'numeric'},...
    {'<=',99},'','Number of residues')

    nport=sqrt(size(Residues(:),1));
    validateattributes(nport,{'numeric'},...
    {'scalar','>=',portSizes(1),'<=',portSizes(2)},...
    mfilename,'Number of ports')

    if(~isequal(size(Poles),size(Residues)))


        if isequal(size(Poles),[1,1])
            Poles=repmat(Poles,nport,nport);
            cacheData.FitOpt=2;

        elseif isequal(size(Poles,1),1)
            Poles=repmat(Poles,nport,1);
            cacheData.FitOpt=1;
        end
    else
        if all(cellfun(@(x)isequal(x,Poles{1,1}),Poles(:)))
            cacheData.FitOpt=2;
        else

            Polesnew=reshape(Poles,[nport,nport]);
            for ii=1:nport
                cacheData.FitOpt=1;
                if~all(cellfun(@(x)isequal(x,Polesnew{1,ii}),Polesnew(:,ii)))
                    cacheData.FitOpt=3;
                    break;
                end
            end
            clear Polesnew;
        end
    end
    cacheData.RationalModel.A=Poles(:);
    cacheData.RationalModel.C=Residues(:);
    cacheData.RationalModel.D=DF(:);
    cacheData.filename=[];
    cacheData.hashcode=0;
    cacheData.timestamp=[];
    cacheData.Impedance=50;


    temp1=cellfun(@length,Poles,'UniformOutput',false);
    temp2=cellfun(@length,Residues,'UniformOutput',false);
    if~all(all(cellfun(@isequal,temp1,temp2)))
        error(message('simrf:simrfV2errors:PoleResidueLengthNotEqual'))
    end

    Poles=cellfun(@(x)x(:),Poles,'UniformOutput',false);
    Residues=cellfun(@(x)x(:),Residues,'UniformOutput',false);
    x=cellfun(@horzcat,Poles,Residues,'UniformOutput',false);
    y=cellfun(@check_poles_residues,x,'UniformOutput',false);

    idxPolesNotEmpty=~cellfun(@isempty,Poles);

    [Aname_cell,Cname_cell,Dname_cell]=get_rational_param_names(nport);
    tempstr=cellfun(@(x)simrfV2vector2str(x(1,:)),y,...
    'UniformOutput',false);
    A=[Aname_cell(idxPolesNotEmpty);reshape(tempstr(idxPolesNotEmpty),...
    1,[])];
    tempstr=cellfun(@(x)simrfV2vector2str(x(2,:)),y,...
    'UniformOutput',false);
    C=[Cname_cell(idxPolesNotEmpty);reshape(tempstr(idxPolesNotEmpty),...
    1,[])];
    D=[Dname_cell;simrfV2vector2str(reshape(DFmat.',1,[]))];

    cacheData.RationalModel.ACell=A;
    cacheData.RationalModel.CCell=C;
    cacheData.RationalModel.DCell=D;
    Z0=50;
    cacheData.RationalModel.Z0Cell={'Z0';...
    simrfV2vector2str(Z0*ones(1,nport))};
    cacheData.NumPorts=nport;

    num_freqs=1001;
    freqs=linspace(0,10e9,num_freqs);
    spars=zeros(nport,nport,num_freqs);
    [row_idx,col_idx]=ind2sub([nport,nport],1:nport^2);
    for idx=1:nport^2
        hRatMod=rfmodel.rational('A',Poles{idx},'C',Residues{idx},...
        'D',DF{idx});
        spars(row_idx(idx),col_idx(idx),:)=freqresp(hRatMod,freqs);
    end
    auxData.Spars.NumPorts=nport;
    auxData.Spars.Impedance=Z0;
    auxData.Spars.Parameters=spars;
    auxData.Spars.Frequencies=freqs;
    set_param([block,'/AuxData'],'UserData',auxData);
    set_param(block,'UserData',cacheData)

end

function[Aname_cell,Cname_cell,Dname_cell]=...
    get_rational_param_names(nport)

    Aname_cell=cell(1,nport*nport);
    Cname_cell=Aname_cell;
    Dname_cell={'D'};
    for ii=1:nport
        for kk=1:nport
            idx=nport*(ii-1)+kk;
            Aname_cell{idx}=sprintf('P%d%d',kk,ii);
            Cname_cell{idx}=sprintf('R%d%d',kk,ii);
        end
    end
end

function y=check_poles_residues(xin)

    x=simrfV2rmconj(xin);
    tempy=[real(x(:,1)),imag(x(:,1)),real(x(:,2)),imag(x(:,2))];


    y=[reshape(tempy(:,1:2).',1,[]);reshape(tempy(:,3:4).',1,[])];
end