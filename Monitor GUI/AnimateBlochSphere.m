function [] = AnimateBlochSphere(blochaxes,startTheta,endTheta,startPhi,endPhi)
blochAxes = blochaxes;
blochStartTheta = startTheta;
blochStartPhi = startPhi;
varpi = pi();
blochEndTheta = endTheta;
blochEndPhi = endPhi;
blochCurrentTheta = blochStartTheta;
blochCurrentPhi = blochStartPhi;
pause('on');

% going to animate at 30 fps. Allow the angles to change at a rate of pi/4
% a second for theta, pi/2 for phi.
numAngleSeconds = 5;%s(blochEndTheta)/(varpi/4);
%numPhiFrames = (blochEndPhi)/(varpi/2);
numAngleFrames = ceil(30*numAngleSeconds);
blochThetaChange = (blochStartTheta-blochEndTheta)/numAngleFrames;
blochPhiChange = (blochStartPhi-blochEndPhi)/numAngleFrames;

for count=1:numAngleFrames
    if(count == 1)
        blochAxes = blochSpherePlot(blochStartTheta,blochStartPhi);
        drawnow
    else
        blochAxes = blochSpherePlot(blochAxes,blochCurrentTheta,blochCurrentPhi,'replot');
        drawnow
    end
    blochCurrentTheta = blochCurrentTheta + blochThetaChange;
    blochCurrentPhi = blochCurrentPhi + blochPhiChange;
    pause(1/30);
end

end