function XFO=ThreePhaseAutotransformerWithTertiaryWindingInit(Set,block,varargin)


    switch Set
    case 'Set1'
        Rmethod=varargin{1};
        VnomL=varargin{2};
        VnomH=varargin{3};
        R12=varargin{4};
        R13=varargin{5};
        R23=varargin{6};
        L12=varargin{7};
        L13=varargin{8};
        L23=varargin{9};
        k=VnomL/VnomH;
        XFO.VnomC=VnomL/sqrt(3);
        XFO.VnomS=(VnomH-VnomL)/sqrt(3);
        switch Rmethod
        case 'Evaluated from RHL, RHT, RLT'
            XFO.Rs=(R12*(1+k)/(1-k)+R13-R23)/(1-k)/2;
            XFO.Rc=(R12-R13+R23)/(1-k)/2;
            XFO.Rd=(-R12+R13+R23*(1-2*k))/(1-k)/2;
            if XFO.Rs<0||XFO.Rc<0||XFO.Rd<0
                R23_max=R12*(1+k)/(1-k)+R13;
                R23_min1=R13-R12;
                R23_min2=(R12-R13)/(1-2*k);
                R23_min=max(R23_min1,R23_min2);
                str=sprintf('Error in autotransformer block \n%s\nIn order to obtain positive winding resistances, you must specify RLT such as:  %g <  RLT < %g pu',block,R23_min,R23_max);
                Erreur.message=str;
                Erreur.identifier='AutoTransformer Block:Parameter Error';
                powericon('psberror',Erreur.message,Erreur.identifier,'NoUiwait')
            end
        case 'Evaluated from RHL, RHT ; same losses in R1 and R2'
            XFO.Rs=R12/2/(1-k)^2;
            XFO.Rc=XFO.Rs;

            XFO.Rd=R13-XFO.Rs*(1-k)^2-XFO.Rc*k^2;
            if XFO.Rd<0
                R13_min=XFO.Rs*(1-k)^2+XFO.Rc*k^2;
                str=sprintf('Error in Autotransformer block \n%s\nIn order to obtain positive delta winding resistance, you must specify RHT such as: RHT > %g pu',block,R13_min);
                Erreur.message=str;
                Erreur.identifier='AutoTransformer Block:Parameter Error';
                powericon('psberror',Erreur.message,Erreur.identifier,'NoUiwait')
            end
        end
        XFO.Ls=(L12*(1+k)/(1-k)+L13-L23)/(1-k)/2;
        XFO.Lc=(L12-L13+L23)/(1-k)/2;
        XFO.Ld=(-L12+L13+L23*(1-2*k))/(1-k)/2;
        if XFO.Ls<0||XFO.Lc<0||XFO.Ld<0
            L23_max=L12*(1+k)/(1-k)+L13;
            L23_min1=L13-L12;
            L23_min2=(L12-L13)/(1-2*k);
            L23_min=max(L23_min1,L23_min2);
            str=sprintf('Error in autotransformer block \n%s\nIn order to obtain positive winding leakage inductances, you must specify LLT such as:  %g <  LLT < %g pu',block,L23_min,L23_max);
            Erreur.message=str;
            Erreur.identifier='AutoTransformer Block:Parameter Error';
            powericon('psberror',Erreur.message,Erreur.identifier,'NoUiwait')
        end
    case 'Set2'


        SpecifyInitialFluxes=varargin{1};
        SetSaturation=varargin{2};
        Measurements=varargin{3};
        BreakLoop=varargin{4};
        DiscreteSolver=varargin{5};
        XFO=[];
        set_param([block,'/Transfo A'],'SetSaturation',SetSaturation);
        set_param([block,'/Transfo A'],'SpecifyInitialFlux',SpecifyInitialFluxes);
        set_param([block,'/Transfo A'],'Measurements',Measurements);
        set_param([block,'/Transfo A'],'BreakLoop',BreakLoop);
        set_param([block,'/Transfo A'],'DiscreteSolver',DiscreteSolver);
        set_param([block,'/Transfo B'],'SetSaturation',SetSaturation);
        set_param([block,'/Transfo B'],'SpecifyInitialFlux',SpecifyInitialFluxes);
        set_param([block,'/Transfo B'],'Measurements',Measurements);
        set_param([block,'/Transfo B'],'BreakLoop',BreakLoop);
        set_param([block,'/Transfo B'],'DiscreteSolver',DiscreteSolver);
        set_param([block,'/Transfo C'],'SetSaturation',SetSaturation);
        set_param([block,'/Transfo C'],'SpecifyInitialFlux',SpecifyInitialFluxes);
        set_param([block,'/Transfo C'],'Measurements',Measurements);
        set_param([block,'/Transfo C'],'BreakLoop',BreakLoop);
        set_param([block,'/Transfo C'],'DiscreteSolver',DiscreteSolver);
    end