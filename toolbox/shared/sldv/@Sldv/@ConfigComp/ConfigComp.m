function this=ConfigComp(subsystemH)




    narginchk(0,1);
    if nargin<1
        subsystemH=[];
    end

    this=Sldv.ConfigComp('Design Verifier');
    this.Description='Design Verifier Custom Configuration Component';

    this.restoreDefaults;

    this.SldvSubComponents=...
    {...
    'Preprocess',...
    'Parameters',...
    'TestGeneration',...
    'ErrorDetection',...
    'AssertionDebug',...
    'Results',...
'Report'...
    };

    if~isa(subsystemH,'Simulink.SubSystem')
        try
            subsystemH=get_param(subsystemH,'Object');
        catch Mex %#ok<NASGU>
            subsystemH=[];
        end
    end

    if~isa(subsystemH,'Simulink.SubSystem')
        subsystemH=[];
    end

    this.SubsystemToAnalyze=subsystemH;


    this.loadComponentDataModel;


