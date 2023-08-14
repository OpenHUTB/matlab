function m_MagResetToDefaults(p)


    enableListeners(p,false);
    p.MagnitudeLimMode='auto';
    p.MagnitudeAxisAngleMode='auto';
    p.MagnitudeTickMode='auto';
    p.MagnitudeFontSizeMultiplier=0.9;
    p.MagnitudeTickLabelVisible=true;
    enableListeners(p,true);


    propChange(p);


    notify(p,'MagnitudeLimChanged');
