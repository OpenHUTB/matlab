


classdef abstractElabHDLComp<dsphdlshared.basiccomp.baseElab

    properties(Access=protected)

        pircomp=[];

    end

    properties(Dependent=true,SetAccess=protected,GetAccess=protected);


Comment
Network
Name
    end

    methods

        function this=abstractElabHDLComp(varargin)


            pv=createUserPVStruct(this,varargin{:});



            setConstructorPVs(this,pv);




            defpvCell=getDefaultPropVals(this);
            defpvStruct=struct(defpvCell{:});
            deffn=fieldnames(defpvStruct);
            for ii=1:numel(deffn),
                if~isfield(pv,deffn{ii}),

                    pv.(deffn{ii})=defpvStruct.(deffn{ii});

                end
            end





            validateClassParams(this,pv);





            this.pircomp=interfaceFcn(this,pv);

        end
    end


    methods(Abstract,Access=protected)
        hC=interfaceFcn(this,pvstruct)
        setConstructorPVs(this,pv)
    end

    methods(Access=private)

        function pv=createUserPVStruct(this,varargin)
            pv=struct(varargin{:});
        end

    end

    methods(Access=protected)

        function validateClassParams(this,pv)






        end

        function c=getDefaultPropVals(this)


            c={'Comment','','Name',''};
        end

        function validationError(this,str)%#ok<MANU>


            error(message('dsp:hdlshared:abstractElabHDLComp:elabCompValidationError',str));
        end

    end

    methods
        function set.Network(this,val)
        end
    end


    methods
        function copyComment(this,oldComp)

            this.pircomp.copyComment(oldComp);
        end
    end

end
