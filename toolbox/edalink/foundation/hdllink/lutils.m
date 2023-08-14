function varargout=lutils(varargin)












    if nargin==0
        nargoutchk(1,1);
        varargout{1}=struct(...
        'ParseCellPvPairs',@ParseCellPvPairs,...
        'PvChangePropName',@PvChangePropName,...
        'PvStruct2Cell',@PvStruct2Cell,...
        'PvCell2Struct',@PvCell2Struct,...
        'GetAvailablePort',@GetAvailablePort,...
        'GenTempRunDir',@GenTempRunDir,...
        'ToTclPath',@ToTclPath,...
        'PathPrepend',@PathPrepend,...
        'PathAppend',@PathAppend,...
        'PathRm',@PathRm,...
        'ChangeProduct',@ChangeProduct,...
        'GetEdaLinkArch',@GetEdaLinkArch,...
        'GetProductName',@GetProductName,...
        'GetProductToolboxDir',@GetProductToolboxDir,...
        'ChangePort',@ChangePort,...
        'GetCosimBlocks',@GetCosimBlocks,...
        'GetToVcdBlocks',@GetToVcdBlocks,...
        'ChangeCosimBlockProp',@ChangeCosimBlockProp,...
        'ChangeToVcdBlockProp',@ChangeToVcdBlockProp,...
        'StructToCellArray',@StructToCellArray...
        );


    else
        if nargout==0
            feval(varargin{:});
        else
            [varargout{1:nargout}]=feval(varargin{:});
        end
    end
end


function availablePort=GetAvailablePort

    availablePort=num2str(getAvailableSocketPort);

end


function rundir=GenTempRunDir(varargin)
    fargs=struct('isLocal',1);
    fargs=ParseCellPvPairs(fargs,varargin);
    if(fargs.isLocal)
        rundir=[pwd,'/run_',strrep(tempname,tempdir,'')];
    else
        rundir=[tempdir,'run_',strrep(tempname,tempdir,'')];
    end
    mkdir(rundir);
end


function tclPath=ToTclPath(filename)
    tclPath=strrep(filename,'\','/');
end


function PathPrepend(varname,varpath)
    PathRm(varname,varpath);
    sp=getenv(varname);
    sp=[varpath,pathsep,sp];
    setenv(varname,sp);
end


function PathRm(varname,varpath)
    sp=getenv(varname);
    escvarpath=regexptranslate('escape',varpath);
    sp=regexprep(sp,['^',escvarpath,pathsep],'');
    sp=regexprep(sp,[pathsep,escvarpath,pathsep],pathsep);
    sp=regexprep(sp,[pathsep,escvarpath,'$'],'');
    setenv(varname,sp);
end


function ChangeProduct(varargin)
    fargs=struct('prodName','rotate');
    fargs=ParseCellPvPairs(fargs,varargin);
    cblks='';vblks='';

    if(strcmpi(fargs.prodName,'lfd')||strcmpi(fargs.prodName,'lfi')||strcmpi(fargs.prodName,'lfm')||strcmpi(fargs.prodName,'lfv'))
        cblks=GetCosimBlocks();
        currblk=cblks;
    else
        vblks=GetToVcdBlocks();
        currblk=vblks;
    end



    currProd=get_param(currblk{1},'ReferenceBlock');
    switch(currProd)
    case 'lfilinklib/HDL Cosimulation',currProd='lfi';
    case 'modelsimlib/HDL Cosimulation',currProd='lfm';
    case 'discoverylib/HDL Cosimulation',currProd='lfd';
    case 'vivadosimlib/HDL Cosimulation',currProd='lfv';
    case 'lfilinklib/To VCD File',currProd='vlfi';
    case 'modelsimlib/To VCD File',currProd='vlfm';
    case 'discoverylib/To VCD File',currProd='vlfd';
    case 'vivadosimlib/To VCD File',currProd='vlfv';
    otherwise
        error(message('HDLLink:lutils:UnsupportedBlock',currProd));
    end

    if(strcmpi(fargs.prodName,'rotate'))
        switch(currProd)
        case 'lfm',dstProd='lfi';
        case 'lfi',dstProd='lfd';
        case 'lfd',dstProd='lfm';
        case 'vlfm',dstProd='vlfi';
        case 'vlfi',dstProd='vlfd';
        case 'vlfd',dstProd='vlfm';
        end
    else
        dstProd=fargs.prodName;
    end



    switch(dstProd)
    case 'lfm',refBlk='modelsimlib/HDL Cosimulation';prodName='EDA Simulator Link MQ';ud='off';
    case 'lfi',refBlk='lfilinklib/HDL Cosimulation';prodName='EDA Simulator Link IN';ud='off';
    case 'lfd',refBlk='discoverylib/HDL Cosimulation';prodName='EDA Simulator Link DS';ud='off';
    case 'lfv',refBlk='vivadosimlib/HDL Cosimulation';prodName='EDA Simulator Link VS';ud='on';
    case 'vlfm',refBlk='modelsimlib/To VCD File';
    case 'vlfi',refBlk='lfilinklib/To VCD File';
    case 'vlfd',refBlk='discoverylib/To VCD File';
    case 'vlfv',refBlk='vivadosimlib/To VCD File';
    otherwise
        error(message('HDLLink:lutils:UnsupportedProduct'));

    end

    if(~isempty(cblks))
        ChangeCosimBlockProp(cblks,'ReferenceBlock',refBlk);
        ChangeCosimBlockProp(cblks,'ProductName',prodName);
        ChangeCosimBlockProp(cblks,'UserDataPersistent',ud);
    else
        ChangeToVcdBlockProp(vblks,'ReferenceBlock',refBlk);
    end
end


function edaArch=GetEdaLinkArch()
    switch(lower(computer))
    case 'glnxa64',edaArch='linux64';
    case 'glnx86',edaArch='linux32';
    case 'sol64',edaArch='solaris64';
    case 'pcwin',edaArch='windows32';
    otherwise
        error(message('HDLLink:lutils:NonSupportedArch'));
    end
end


function prodName=GetProductName(blkName)
    refName=get_param(blkName,'ReferenceBlock');
    switch(refName)
    case 'modelsimlib/HDL Cosimulation',prodName='EDA Simulator Link MQ';
    case 'lfilinklib/HDL Cosimulation',prodName='EDA Simulator Link IN';
    case 'discoverylib/HDL Cosimulation',prodName='EDA Simulator Link DS';
    otherwise
        error(message('HDLLink:lutils:UnsupportedCosimBlock'));
    end
end


function dirName=GetProductToolboxDir(prodName)
    switch(prodName)
    case 'EDA Simulator Link MQ',tbName='modelsim';
    case 'EDA Simulator Link IN',tbName='incisive';
    case 'EDA Simulator Link DS',tbName='discovery';
    otherwise
        error(message('HDLLink:lutils:UnsupportedSimulator'));
    end
    dirName=fullfile(matlabroot,'toolbox','edalink','extensions',tbName);
end


function ChangePort(varargin)
    fargs=struct('port',0);
    fargs=ParseCellPvPairs(fargs,varargin);

    if(fargs.port==0)
        port=GetAvailablePort();
    else
        port=fargs.port;
    end


    cblks=GetCosimBlocks();


    ChangeCosimBlockProp(cblks,'CommSharedMemory','off');
    ChangeCosimBlockProp(cblks,'CommPortNumber',port);
    ChangeCosimBlockProp(cblks,'CommLocal','on');
end


function cblks=GetCosimBlocks()

    cblks=find_system(bdroot,'FollowLinks','on','Regexp','on',...
    'ReferenceBlock','HDL Cosimulation');
    if(isempty(cblks))
        warning(message('HDLLink:lutils:NoCosimBlocks',bdroot));
        return;
    end
end

function tovcdblks=GetToVcdBlocks()

    tovcdblks=find_system(bdroot,'FollowLinks','on','Regexp','on',...
    'ReferenceBlock','To VCD File');
    if(isempty(tovcdblks))
        warning(message('HDLLink:lutils:NoToVcdBlocks',bdroot));
        return;
    end
end

function ChangeCosimBlockProp(blkList,propName,propVal)
    arrayfun(@(x)(set_param(char(x),propName,propVal)),blkList);

    bdo=get_param(bdroot,'Object');
    bdo.refreshModelBlocks;
end


function ChangeToVcdBlockProp(blkList,propName,propVal)
    arrayfun(@(x)(set_param(char(x),propName,propVal)),blkList);

    bdo=get_param(bdroot,'Object');
    bdo.refreshModelBlocks;
end



function cellArray=StructToCellArray(inStruct)
    fnames=fieldnames(inStruct);
    cellArray=cell(length(fnames)*2,1);
    ica=1;
    for ifn=1:length(fnames)
        cellArray{ica}=fnames{ifn};
        ica=ica+1;
        cellArray{ica}=inStruct.(fnames{ifn});
        ica=ica+1;
    end
end


function cellPv=PvStruct2Cell(inStruct)
    cellvals=struct2cell(inStruct);
    cellprops=fieldnames(inStruct);
    matpv=[cellprops,cellvals];
    matpvprime=matpv';
    cellPv=matpvprime(:);
end


function structPv=PvCell2Struct(inCell)
    cdim=size(inCell);
    if(~(length(cdim)==2&&logical(find(cdim==1))))
        error(message('HDLLink:lutils:BadCellDim'));
    else
        if(cdim(2)>cdim(1))
            inCell=inCell';
        end
    end
    cellvals=inCell(2:2:end);
    cellprops=inCell(1:2:end);
    structPv=cell2struct(cellvals,cellprops,1);
end


function pv=PvChangePropName(pv,origName,newName)
    inputIsCell=false;
    if(iscell(pv))
        pv=PvCell2Struct(pv);
        inputIsCell=true;
    end

    if(~isfield(pv,origName))
        error(message('HDLLink:lutils:NotValidField',origName));
    end

    pv.(newName)=pv.(origName);
    pv=rmfield(pv,origName);

    if(inputIsCell)
        pv=PvStruct2Cell(pv);
    end
end


function pv=ParseCellPvPairs(defaultPv,inArgs)

    if(mod(length(inArgs),2)~=0)
        error(message('HDLLink:lutils:MissingArgument',char(fieldnames(defaultPv))));
    end

    pv=defaultPv;
    for ix=1:2:length(inArgs)
        p=inArgs{ix};
        v=inArgs{ix+1};
        if(isfield(defaultPv,p))
            pv.(p)=v;
        else
            error(message('HDLLink:lutils:BadParameter',p,char(fieldnames(defaultPv))'));
        end
    end
end




