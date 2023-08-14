



function type=convertDataType(this,funSpec,argSpec,varargin)



    p=inputParser;
    p.addParameter('WorkspaceName','',...
    @(x)validateattributes(x,{'char'},{}));
    p.parse(varargin{:});
    lWorkspaceName=p.Results.WorkspaceName;

    try

        if this.Specs.Options.stubSimBehavior&&strcmp(argSpec.DataKind,'DWork')



            dataTypeId=this.DataTypes.addOpaqueType(argSpec.Data.DataTypeName);
        else
            dataTypeId=this.DataTypes.addNamedType(argSpec.Data.DataTypeName,...
            this.Specs.Options.namedTypeSource,...
            'StubSimBehavior',this.Specs.Options.stubSimBehavior,...
            'WorkspaceName',lWorkspaceName);
        end
    catch Me

        lctErrIdRadix=legacycode.lct.spec.Common.LctErrIdRadix;



        if strncmp(lctErrIdRadix,Me.identifier,numel(lctErrIdRadix))&&~isempty(funSpec)


            legacycode.lct.spec.Common.error(...
            'LCTErrorRethrowErrorWithSpec',...
            funSpec.Expression,...
            argSpec.PosOffset,numel(argSpec.Expression),Me.message);
        else

            rethrow(Me)
        end
    end


    if dataTypeId>this.DataTypes.NumSLBuiltInDataTypes
        this.DataTypes.Items(dataTypeId).IsPartOfSpec=true;
    end


    type=this.DataTypes.Items(dataTypeId);
