function setChangeInformationEnabled( this, toEnable, cViews )
arguments
    this
    toEnable
    cViews = this.getAllViewers;
end

for i = 1:numel( cViews )
    cViews{ i }.displayChangeInformation = toEnable;
end
end
