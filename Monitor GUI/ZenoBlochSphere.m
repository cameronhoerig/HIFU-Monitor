function [] = ZenoBlochSphere(blochaxes,startTheta,endTheta,startPhi,endPhi, numMeasurements)
blochAxes = blochaxes;
blochStartTheta = startTheta;
blochStartPhi = startPhi;
varpi = pi();
blochEndTheta = endTheta;
blochEndPhi = endPhi;
blochCurrentTheta = blochStartTheta;
blochCurrentPhi = blochStartPhi;
pause('on');
randoms = rand(1,150);

numAngleSeconds = 5;%(blochEndTheta)/(varpi/4);
%numPhiFrames = (blochEndPhi)/(varpi/2);
numAngleFrames = ceil(30*numAngleSeconds);
blochThetaChange = (blochStartTheta-blochEndTheta)/numAngleFrames;
blochPhiChange = (blochStartPhi-blochEndPhi)/numAngleFrames;
delTMeasure = floor(numAngleFrames/numMeasurements);    
currentMeasureTime = delTMeasure;

for count=1:numAngleFrames
    if(count == 1)
        blochAxes = blochSpherePlot(blochStartTheta,blochStartPhi);
        drawnow
    else
        blochAxes = blochSpherePlot(blochAxes,blochCurrentTheta,blochCurrentPhi,'replot');
        drawnow
    end
    if(currentMeasureTime < count)
        thetaProb = cos(blochCurrentTheta);
        thetaProb = thetaProb^2;
        randomNum = rand(1);
        if(thetaProb >= randomNum)
            blochCurrentTheta = 0;
            blochCurrentPhi = 0;
        end
        currentMeasureTime = currentMeasureTime+delTMeasure;
    end
    blochCurrentTheta = blochCurrentTheta + blochThetaChange;
    blochCurrentPhi = blochCurrentPhi + blochPhiChange;
    pause(1/30);
end

end