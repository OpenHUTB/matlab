
classdef HDLLookupTableScaled<coder.internal.mathfcngenerator.HDLLookupTable
    properties
        Scale;
    end

    methods(Access=protected)
        function candidate_function_call=getCandidateFunctionCall(obj)
            candidate_function_call=[num2str(obj.Scale),'*',getCandidateFunctionCall@coder.internal.mathfcngenerator.HDLLookupTable(obj)];
        end
    end

    methods
        function obj=HDLLookupTableScaled(template_parent,options,varargin)
            if(nargin<2)
                options='';
            end

            obj=obj@coder.internal.mathfcngenerator.HDLLookupTable(varargin{:});


            p=properties(template_parent);
            for itr=1:length(p)
                if(isprop(obj,p{itr}))
                    obj.(p{itr})=template_parent.(p{itr});
                end
            end

            if(nargin<2)

                obj.Scale='180/pi';

                obj.CandidateFunction=str2func([func2str(obj.CandidateFunction),'*',obj.Scale]);
            else
                switch(options)
                case 'ScaleInputDegree2Radian'

                    obj.Scale='pi/180';


                    obj.CandidateFunction=str2func(['@(x) feval(',func2str(obj.CandidateFunction),',x*',obj.Scale,')']);

                    obj.InputExtents=[0,360];

                otherwise
                    error(message('float2fixed:MFG:UnsupportedModeScaledLUT'));
                end
            end
        end
    end
end
