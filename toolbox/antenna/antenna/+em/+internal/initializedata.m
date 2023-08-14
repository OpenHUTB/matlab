function[Horizontal,Vertical,Optional]=initializedata()

    Horizontal=struct;
    Vertical=struct;
    Optional=struct;

    Horizontal.PhysicalQuantity=[];
    Horizontal.Magnitude=[];
    Horizontal.Units=[];
    Horizontal.Azimuth=[];
    Horizontal.Elevation=[];
    Horizontal.Frequency=[];
    Horizontal.Slice=[];

    Vertical.PhysicalQuantity=[];
    Vertical.Magnitude=[];
    Vertical.Units=[];
    Vertical.Azimuth=[];
    Vertical.Elevation=[];
    Vertical.Frequency=[];
    Vertical.Slice=[];

    Horizontal.Elevation=0;
    Vertical.Azimuth=0;

    Horizontal.Slice='Elevation';
    Vertical.Slice='Azimuth';

    Horizontal.PhysicalQuantity='Gain';
    Vertical.PhysicalQuantity='Gain';

    Horizontal.Units='dBd';
    Vertical.Units='dBd';

end

