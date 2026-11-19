#if UNITY_EDITOR
using UnityEngine;
using VRC;
using VRC.SDKBase;
using VRC.SDK3.Dynamics.Constraint.Components;

namespace Purpzie.SmoothRemoteScaling {
	/// <summary>
	/// Even though VRCFury has a CS Retarget component, it doesn't account for scale offsets. It also
	/// doesn't give the constraint enough time to determine its execution order or dependent
	/// physbones (I think?). This component assigns the hips *before* upload so that those things can
	/// happen. Hopefully that makes everything much more stable.
	/// </summary>
	[AddComponentMenu("")]
	[ExecuteAlways]
	internal class AssignHipsToConstraint : MonoBehaviour, IEditorOnly {
		private void SetupConstraint() {
			if (!TryGetComponent<VRCScaleConstraint>(out var constraint)) return;

			var animator = GetComponentInParent<Animator>();
			if (animator == null) {
				SetTargetTransform(constraint, null);
				return;
			}

			var hips = animator.GetBoneTransform(HumanBodyBones.Hips);
			if (hips == null) {
				SetTargetTransform(constraint, null);
				return;
			}

			SetTargetTransform(constraint, hips);
		}

		private void SetTargetTransform(VRCScaleConstraint constraint, Transform transform) {
			if (constraint.TargetTransform != transform) {
				constraint.TargetTransform = transform;
				constraint.ScaleAtRest = transform == null ? Vector3.one : transform.localScale;
				constraint.ScaleOffset = transform == null ? Vector3.one : transform.lossyScale;
				constraint.ApplyConfigurationChanges();
				constraint.MarkDirty();
			}
		}

		private void Awake() => SetupConstraint();
		private void OnTransformParentChanged() => SetupConstraint();
	}
}
#endif
