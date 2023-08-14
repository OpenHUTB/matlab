classdef EML < controldesign.blockconfig.GainSurface
    % This class contains the interface methods for the MATLAB Function block
    
    % Author(s): P. Gahinet
    % Copyright 2010-2017 The MathWorks, Inc.
            
    methods (Access = public)

      function this = EML(BlockPath)
          % Constructor
          if nargin==0
             return
          end
          this.BlockPath = BlockPath;
          % Put model in compiled state
          [precompiled,ModelParameterMgr] = this.preprocessModel(getModelName(this));
          try
             feature('EngineInterface',Simulink.EngineInterfaceVal.byFiat)
             r = get_param(BlockPath,'RunTimeObject');
             % Should be only one output port
             if r.NumOutputPorts~=1
                error(message('Slcontrol:controldesign:EML1',this.BlockPath))
             end
             % Number of scheduling variables (input arguments)
             this.NDIM_ = r.NumInputPorts;
             % Generic initialization for GainSurface blocks
             initialize(this)
             % Cleanup
             this.postprocessModel(precompiled,ModelParameterMgr)
          catch ME
             this.postprocessModel(precompiled,ModelParameterMgr)
             throw(ME)
          end
       end
       
       function TC = getDefaultParameterization(this)
          % Default parameterization: tunableGain initialized at zero
          TC = tunableGain(this.Name,zeros(this.IOSize_));
          TC.Ts = this.Ts;
       end
       
       function readValueFromSLMaskParameters(this,~)
          error(message('Slcontrol:controldesign:EML2',this.BlockPath))
       end
       
       function writeValueToSLMaskParameters(this,~)
          error(message('Slcontrol:controldesign:EML3',this.BlockPath))
       end
       
       function writeParamToSLMaskParameters(this)
          % Write code back to Simulink block
          TC = this.Parameterization;
          if nmodels(TC)==1
             % Fixed gain or static model
             GainValue = getValue(TC);
             if isa(GainValue,'ss')
                GainValue = GainValue.d;
             end
             pNames = "x" + (1:this.NDIM_);
             args = sprintf('%s,',pNames);
             reftype = sprintf('%s+',pNames);
             Code = [...
                "function Gain_ = fcn(" + args(1:end-1) + ")"
                "%#codegen"
                ""
                "Gain_ = cast(" + mat2str(GainValue) + ",'like'," + reftype(1:end-1) + ");"];
             Code = sprintf('%s\n',Code);
          elseif isa(TC,'tunableSurface')
             Code = codegen(TC);
          else
             warning(message('Slcontrol:controldesign:EML4',this.BlockPath))
             return
          end
          % Write M code to block
          S = sfroot;
          ch = S.find('Path',this.BlockPath,'-isa','Stateflow.EMChart');
          ch.Script = Code;
       end
       
    end
        
end
