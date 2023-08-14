function r=checkTotalTripDuration(data,params)





    r=RDE.functions.constraintInsideBounds(seconds(data.t(end)),params.TripDurationRange(1),params.TripDurationRange(2));
end