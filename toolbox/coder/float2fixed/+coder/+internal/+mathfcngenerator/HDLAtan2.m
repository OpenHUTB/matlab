




classdef HDLAtan2<coder.internal.mathfcngenerator.HDLDivide
    properties
ATan
    end

    methods(Access=protected)
        function candidate_function_call=getCandidateFunctionCall(obj)
            candidate_function_call='atan2(%s,%s)';
        end
    end

    methods
        function obj=HDLAtan2(varargin)
            obj=obj@coder.internal.mathfcngenerator.HDLDivide(varargin{:});
            obj.ATan=coder.internal.mathfcngenerator.HDLAtan(varargin{:});
            obj.ATan.N=obj.N;
            obj.ATan.InputDomain=obj.InputDomain;
            obj.DefaultRange=[0.01,1e2];
        end
    end

    methods(Access=public)
        function z=setup(obj,y,x)
            if(obj.RequireSetup())
                obj.setup_internal(x);
            end
            if(abs(x)<50*eps)

                if(abs(y)<50*eps)
                    z=0;
                elseif(y<0)
                    z=-pi/2;
                else
                    z=+pi/2;
                end

            else


                ratio=obj.doDivide(y,abs(x));



                if(x<0)
                    if(y>=0)
                        z=pi;
                    else
                        z=-pi;
                    end
                else
                    z=0;
                end


                val=setup(obj.ATan,ratio);
                if(x<0)
                    val=-val;
                end
                z=z+val;
            end

        end
    end

    methods(Access=public)
        function[code,function_name,code_tb]=generateMATLAB(obj,function_name)
            if(obj.RequireSetup())
                obj.setup_internal(obj.InputExtents(1));
                obj.setup(obj.InputExtents(1),obj.InputExtents(1));
            end
            assert(numel(obj.LUT)>0,'LUT size must be non-zero')
            if(nargin<2)
                function_name=strrep(class(obj),'.','_');
            end
            [pathParent,~,~]=fileparts(mfilename('fullpath'));

            atan_function_name=[function_name,'_atan'];
            obj.ATan.GenFixptCode=obj.GenFixptCode;
            atan_function_body=obj.ATan.generateMATLAB(atan_function_name);%#ok<NASGU>

            div_function_name=[function_name,'_div'];
            div_function_body=generateMATLAB@coder.internal.mathfcngenerator.HDLDivide(obj,div_function_name);%#ok<NASGU>

            InputDomain=obj.InputDomain;%#ok<NASGU>
            GenFixptCode=obj.GenFixptCode;
            N=obj.N;
            InterpolationDegree=obj.InterpolationDegree;
            code=coder.internal.tools.TML.render(fullfile(pathParent,'hdl_lookup_skeleton_atan2.tpl.m'));
            code=obj.prettyPrint(code);
            code_tb=obj.generateTB(function_name);
        end
    end
end
