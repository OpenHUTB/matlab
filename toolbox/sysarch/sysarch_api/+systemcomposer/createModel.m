function zcModel=createModel(modelname,varargin)



















    narginchk(1,3);

    if nargin==1
        architectureType='Architecture';
        openFlag=false;
    elseif nargin==2
        if isa(varargin{1},'char')||isa(varargin{1},'string')
            architectureType=varargin{1};
            openFlag=false;
        else
            architectureType='Architecture';
            openFlag=varargin{1};
        end
    else
        architectureType=varargin{1};
        openFlag=varargin{2};
    end


    systemcomposer.internal.validateArchitectureType(architectureType);


    validateattributes(openFlag,{'logical','double'},{'scalar'},'','OPENFLAG');

    [~,mdlName,~]=fileparts(modelname);
    bdHandle=new_system(mdlName,architectureType);
    zcModel=systemcomposer.arch.Model(bdHandle);
    if openFlag
        systemcomposer.openModel(zcModel.Name);
    end

end
