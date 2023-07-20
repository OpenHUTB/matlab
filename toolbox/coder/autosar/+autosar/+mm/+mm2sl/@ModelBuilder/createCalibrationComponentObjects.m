




function createCalibrationComponentObjects(self,m3iComp,varargin)

    argParser=createArgParser();


    argParser.parse(self,m3iComp,varargin{:});


    ddName=argParser.Results.DataDictionary;
    if~isempty(ddName)
        workSpace=Simulink.dd.open(ddName);

    else
        workSpace='base';
    end
    modelWorkSpace=get_param(self.slModelName,'ModelWorkspace');


    if ischar(m3iComp)||isStringScalar(m3iComp)
        m3iObj=autosar.mm.Model.findChildByName(self.m3iModel,m3iComp);
        if isempty(m3iObj)||~isa(m3iObj,'Simulink.metamodel.arplatform.component.ParameterComponent')
            self.msgStream.createWarning('RTW:autosar:badImportedCalibrationComponent',m3iComp);
            return
        end
        m3iComp=m3iObj;
        self.slTypeBuilder.buildAllDataTypeMappings(m3iComp.rootModel);
    end


    if~m3iComp.isvalid()
        msg=DAStudio.message('RTW:autosar:mmInvalidArgObject',2,...
        'Simulink.metamodel.arplatform.component.ParameterComponent');
        assert(false,msg);
    end


    self.m3iModel.beginTransaction();



    self.slParameterBuilder.slTypeBuilder.keepSLObj=argParser.Results.CreateSimulinkObject;
    self.slParameterBuilder.buildParameterComponent(workSpace,modelWorkSpace,m3iComp,argParser.Results.UseLegacyWorkspaceBehavior);


    self.slParameterBuilder.slTypeBuilder.createAll(workSpace);

    if isempty(ddName)

        enumFileName=[m3iComp.Name,'_defineIntEnumTypes'];
        enumFileName=autosar.mm.mm2sl.ModelBuilder.checkEnumFileName(argParser.Results.NameConflictAction,enumFileName);
        enumFileName=[enumFileName,'.m'];
        self.slParameterBuilder.slTypeBuilder.createEnumsFile(enumFileName);
    end


    if~isempty(ddName)
        workSpace.explore();
        workSpace.close();
    end

    self.m3iModel.commitTransaction();

    function argParser=createArgParser()

        argParser=inputParser();
        argParser.addRequired('self',@(x)isa(x,class(x)));
        argParser.addRequired('m3iComp',@(x)((ischar(x)||isStringScalar(x))||isa(x,'Simulink.metamodel.arplatform.component.ParameterComponent')));
        argParser.addParameter('CreateSimulinkObject',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
        argParser.addParameter('NameConflictAction','overwrite',@(x)any(strcmpi(x,{'overwrite','makenameunique','error'})));
        argParser.addParameter('DataDictionary','',@(x)(ischar(x)||isStringScalar(x)));
        argParser.addParameter('UseLegacyWorkspaceBehavior',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));


