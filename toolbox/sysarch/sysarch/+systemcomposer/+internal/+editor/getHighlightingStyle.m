function style=getHighlightingStyle





    purple=[0.5,0.0,0.5,0.8];

    stroke=MG2.Stroke;
    stroke.Color=purple;
    stroke.Width=3;
    trace=MG2.TraceEffect(stroke,'Outer');

    glow=MG2.GlowEffect();
    glow.Color=purple;
    glow.Spread=10;
    glow.Gain=1;

    style=diagram.style.Style;
    style.set('Trace',trace);
    style.set('Glow',glow);

end