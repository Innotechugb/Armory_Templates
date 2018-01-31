package arm;

import iron.math.Mat4;
import iron.math.Vec4;
import iron.Trait;
import iron.system.Input;
import iron.system.Time;
import iron.object.Object;
import iron.object.Transform;
import iron.object.CameraObject;
import armory.trait.physics.RigidBody;

@:keep
class GunController extends Trait {

#if (!arm_physics)
	public function new() { super(); }
#else

	var projectileRef:String;
	var firePoint:Transform;
	var fireStrength = 25;

	public function new(projectileRef:String, firePointRef:String) {
		super();

		this.projectileRef = projectileRef;
		
		notifyOnInit(function() {
			firePoint = object.getChild(firePointRef).transform;
		});
		
		notifyOnUpdate(function() {
			if (Input.getMouse().started("left")) shoot();
		});
	}

	function shoot() {
		// Spawn projectile
		iron.Scene.active.spawnObject(projectileRef, null, function(o:Object) {
			o.transform.loc.x = firePoint.worldx();
			o.transform.loc.y = firePoint.worldy();
			o.transform.loc.z = firePoint.worldz();
			o.transform.buildMatrix();
			// Apply force
			var rb:RigidBody = o.getTrait(RigidBody);
			rb.syncTransform();
			var look = object.transform.look().normalize();
			rb.setLinearVelocity(look.x * fireStrength, look.y * fireStrength, look.z * fireStrength);
			// Remove projectile after a period of time
			kha.Scheduler.addTimeTask(function() {
				o.remove();
			}, 10);
		});
	}

#end
}
