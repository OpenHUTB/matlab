function r=getXilinxDeviceList(varargin)


    iseFamilyList={'Spartan3','Spartan3A and Spartan3AN','Spartan3E','Spartan-3A DSP','Spartan6','Virtex4',...
    'Virtex5','Virtex6'};

    vivadoFamilyList=eda.internal.fpgadevice.getXilinxVivadoFPGAFamilies;

    familyList=sort([iseFamilyList,vivadoFamilyList]);

    if nargin==0
        r=familyList;
    else
        family=varargin{1};
        switch family
        case vivadoFamilyList
            r=eda.internal.fpgadevice.getXilinxVivadoDeviceList(varargin{:});
        otherwise
            r=getDefaultXilinxPartList(varargin{:});
        end
    end

end
