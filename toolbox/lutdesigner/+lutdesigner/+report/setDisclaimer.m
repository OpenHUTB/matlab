function disclaimerHead=setDisclaimer(rpt,message)
    import mlreportgen.dom.*

    disclaimerHead=Paragraph(message);
    disclaimerHead.Color='red';
    disclaimerHead.Bold=1;
    disclaimerHead.FontSize='30';
    disclaimer=Group();
    append(disclaimer,disclaimerHead);
    append(rpt,disclaimer);
end
