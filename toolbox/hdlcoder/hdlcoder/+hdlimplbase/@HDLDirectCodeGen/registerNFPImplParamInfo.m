function panelLayout=registerNFPImplParamInfo(this,hasDenormal,hasMantissa,hasCustomLatency)





    if nargin<2
        hasDenormal=false;
    end

    if nargin<3
        hasMantissa=false;
    end

    if nargin<4
        hasCustomLatency=false;
    end



    panelLayout=struct;
    panelLayout.tabName='Native Floating Point';
    panelLayout.tabPosition=2;
    panelLayout.groupName='Implementation Parameters';
    panelLayout.groupPosition=1;






    if(hasDenormal)
        this.addImplParamInfo('HandleDenormals','ENUM','inherit',{'inherit','on','off'},panelLayout);
    end

    if(hasCustomLatency)
        this.addImplParamInfo('LatencyStrategy','ENUM','inherit',{'inherit','Max','Min','Zero','Custom'},panelLayout);

        this.addImplParamInfo('NFPCustomLatency','POSINT',0,[],panelLayout);
    else
        this.addImplParamInfo('LatencyStrategy','ENUM','inherit',{'inherit','Max','Min','Zero'},panelLayout);
    end

    if(hasMantissa)
        this.addImplParamInfo('MantissaMultiplyStrategy','ENUM','inherit',{'inherit','FullMultiplier','PartMultiplierPartAddShift','NoMultiplierFullAddShift'},panelLayout);
    end


