function [bouts, amps] = computeBouts(sd)
	% [bouts, amps] = computeBouts(sd) returns the bouts and amplitudes of 
	% the first derivative, sd, of a signal.	
    sdd = diff(sd); % Second derivative
    sd_pos = sdd >=0; % positive part of the derivative
    signchange = diff(sd_pos); %Change neg->pos=1, pos->neg=-1.
    pos_changes = find(signchange > 0);
    neg_changes = find(signchange < 0);
    % have to ensure that first change is positive, and every pos. change is complemented by a neg. change
    if pos_changes(1) > neg_changes(1) % first change is negative
        %discard first negative change
        neg_changes = neg_changes(2:end);
    end
    if length(pos_changes) > length(neg_changes) % lengths must be equal
        difference = length(pos_changes) - length(neg_changes);
        pos_changes = pos_changes(1:end-difference);
    end
    bouts = zeros(length(pos_changes),2);
    bouts(:,1) = pos_changes;
    bouts(:,2) = neg_changes;
    amps = sd(bouts);
    amps = amps(:,2) - amps(:,1);
end