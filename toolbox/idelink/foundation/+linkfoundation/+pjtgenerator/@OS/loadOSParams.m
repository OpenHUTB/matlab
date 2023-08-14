function hOs=loadOSParams(hOs,osNameOrAlias)










    hOs.configSetSettings={...
    'PositivePriorityOrder','setPropEnabled','on';...
    'PositivePriorityOrder','setProp','on';...
    'PositivePriorityOrder','setPropEnabled','off';...
    };

    switch(osNameOrAlias)
    case{'BareBoard','bareboard','None','none'}
        hOs.name='BareBoard';
        hOs.alias='bareboard';
        hOs.maxRealTimePriority=inf;
        hOs.minRealTimePriority=-inf;
        hOs.minSystemStackSize=0;
        hOs.mainIsAThread=1;
        hOs.isProcessorAware=1;
        hOs.baseRatePriority=40;
        hOs.configSetSettings=struct([]);
    case{'Linux','linux'}
        hOs.name='Linux';
        hOs.alias='linux';
        hOs.maxRealTimePriority=99;
        hOs.minRealTimePriority=1;
        hOs.minSystemStackSize=16384;
        hOs.mainIsAThread=1;
        hOs.isProcessorAware=0;
        hOs.baseRatePriority=40;
        hOs.configSetSettings={...
        'PositivePriorityOrder','setPropEnabled','on';...
        'PositivePriorityOrder','setProp','on';...
        'PositivePriorityOrder','setPropEnabled','off';...
        };
    case{'Windows','windows'}
        hOs.name='Windows';
        hOs.alias='windows';
        hOs.maxRealTimePriority=11;
        hOs.minRealTimePriority=6;
        hOs.minSystemStackSize=16384;
        hOs.mainIsAThread=1;
        hOs.isProcessorAware=0;
        hOs.baseRatePriority=10;
        hOs.configSetSettings={...
        'PositivePriorityOrder','setPropEnabled','on';...
        'PositivePriorityOrder','setProp','on';...
        'PositivePriorityOrder','setPropEnabled','off';...
        };
    case{'VxWorks','vxworks'}
        hOs.name='VxWorks';
        hOs.alias='vxworks';
        hOs.maxRealTimePriority=255;
        hOs.minRealTimePriority=0;
        hOs.minSystemStackSize=16384;
        hOs.mainIsAThread=1;
        hOs.isProcessorAware=0;
        hOs.baseRatePriority=60;
        hOs.configSetSettings={...
        'PositivePriorityOrder','setPropEnabled','on';...
        'PositivePriorityOrder','setProp','off';...
        'PositivePriorityOrder','setPropEnabled','off';...
        };
    case{'DSP/BIOS','dspbios'}
        hOs.name='DSP/BIOS';
        hOs.alias='dspbios';
        hOs.needsAdditionalFiles=1;
        hOs.maxRealTimePriority=15;
        hOs.minRealTimePriority=1;
        hOs.minSystemStackSize=1024;
        hOs.mainIsAThread=0;
        hOs.isProcessorAware=1;
        hOs.baseRatePriority=7;
        hOs.configSetSettings={...
        'PositivePriorityOrder','setPropEnabled','on';...
        'PositivePriorityOrder','setProp','on';...
        'PositivePriorityOrder','setPropEnabled','off';...
        };
    otherwise
        hOs=[];
    end


    if~isempty(hOs)&&~isempty(hOs.configSetSettings)
        Fields={'Name','Method','Value'};
        hOs.configSetSettings=cell2struct(hOs.configSetSettings,Fields,2);
    end

end