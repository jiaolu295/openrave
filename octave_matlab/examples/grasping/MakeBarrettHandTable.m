% GraspTable = MakeBarrettHandTable(targetfilename, grasptablefilename)
%
% Makes grasp tables for a particular name and targetfilename combination.
% For example: MakeBarrettHandTable('mug1','data/mug1.kinbody.xml')
% 

% Copyright (C) 2008-2010 Rosen Diankov
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
function GraspTable = MakeBarrettHandTable(targetfilename, grasptablefilename)

global probs
addopenravepaths_grasping();

thresh = 0;

% default parameters
if( ~exist('targetfilename','var') )
    targetfilename = 'data/mug1.kinbody.xml';
end

% extract name from targetfilename
[tdir, name, text] = fileparts(targetfilename);

dots = strfind(name, '.');
if( ~isempty(dots) && dots(1) > 1)
    name = name(1:(dots(1)-1));
end

if( ~exist('grasptablefilename','var') )
    grasptablefilename = sprintf('grasptables/grasp_barrett_%s.mat', name);
end

orEnvLoadScene('',1); % clear the scene

% setup the robot
robot = RobotCreateHand('TestHand','robots/barretthand.robot.xml');
probs.grasp = orEnvCreateProblem('Grasper', robot.name);

% 3 preshapes
preshapes = transpose([0.5 0.5 0.5 pi/3;
             0.5 0.5 0.5 0;
             0 0 0 pi/2]);

% setup the target
Target.name = name;
Target.filename = targetfilename;
Target.id = orEnvCreateKinBody(Target.name, Target.filename);

if( Target.id == 0 )
    error(['could not create body ' Target.filename]);
end

orBodySetTransform(Target.id, [0 0 0], [1 0 0 0]); % identity

% start simulating grasps
[GraspTable, GraspStats] = MakeGraspTable(robot,Target,preshapes);

% save the table
GraspTable = GraspTable(find(GraspStats(:,1) > 0),:);
save('-v6',grasptablefilename,'GraspTable','robot','targetfilename');

GraspTableSimple = GraspTable(:,[robot.grasp.transform robot.grasp.joints]);
[d,n,e] = fileparts(grasptablefilename);
save('-ascii',fullfile(d,['simple_' n e]),'GraspTableSimple');
