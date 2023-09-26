using UnityEngine;
using System.Collections;

public class CameraController : MonoBehaviour
{
	public Transform targetFocus;
	public GameObject targetObj;
	public float height = 0.0f;
	public float offset = 0.0f;
	public float distance = 3.5f;
	[Range(0.1f, 4f)] public float ZoomWheelSpeed = 4.0f;

	public float minDistance = 1f;
	public float maxDistance = 4f;

	public float xSpeed = 250.0f;
	public float ySpeed = 120.0f;

	public float yMinLimit = -10;
	public float yMaxLimit = 60;

	public float objRotateSpeed = 500.0f;

	//
	private float x = 0.0f;
	private float y = 0.0f;

	private float normal_angle = 0.0f;

	private float cur_distance = 0;

	private float cur_xSpeed = 0;
	private float cur_ySpeed = 0;
	private float req_xSpeed = 0;
	private float req_ySpeed = 0;

	private float cur_ObjRotateSpeed = 0;
	private float req_ObjRotateSpeed = 0;

	[Tooltip("KeyCode L")]
	public bool isLock = false;
	[Tooltip("KeyCode `")]
	public bool isLockRolling = false;
	private Collider[] surfaceColliders;
	private float bounds_MaxSize = 20;

	[HideInInspector] public bool disableSteering = false;

	void Start()
	{
		Vector3 angles = transform.eulerAngles;
		x = angles.y;
		y = angles.x;

		Reset();
	}

	public void DisableSteering(bool state)
	{
		disableSteering = state;
	}

	public void Reset()
	{

		disableSteering = false;

		cur_distance = distance;
		cur_xSpeed = 0;
		cur_ySpeed = 0;
		req_xSpeed = 0;
		req_ySpeed = 0;
		surfaceColliders = null;

		cur_ObjRotateSpeed = 0;
		req_ObjRotateSpeed = 0;

		//if (targetObj) {
		//	Renderer[] renderers = targetObj.GetComponentsInChildren<Renderer>();
		//	Bounds bounds = new Bounds();
		//	bool initedBounds=false;
		//	foreach(Renderer rend in renderers) {
		//		if (!initedBounds) {
		//			initedBounds=true;
		//			bounds=rend.bounds;
		//		} else {
		//			bounds.Encapsulate(rend.bounds);
		//		}
		//	}
		//	Vector3 size = bounds.size;
		//	float dist = size.x>size.y ? size.x : size.y;
		//	dist = size.z>dist ? size.z : dist;
		//	bounds_MaxSize = dist;
		//	cur_distance += bounds_MaxSize*1.2f;

		//	surfaceColliders = targetObj.GetComponentsInChildren<Collider>();
		//}
	}
	void LateUpdate()
	{
		if (Input.GetKey(KeyCode.E))
		{
			height += 0.005f;
		}
		if (Input.GetKey(KeyCode.Q))
		{
			height -= 0.005f;
		}
		//if (Input.GetKey(KeyCode.LeftArrow))
		//{
		//	offset -= 0.005f;
		//}
		//if (Input.GetKey(KeyCode.RightArrow))
		//{
		//	offset += 0.005f;
		//}
		if (Input.GetKeyDown(KeyCode.L))
		{
			isLock = !isLock;
		}
		if (Input.GetKeyDown(KeyCode.BackQuote))
		{
			isLockRolling = !isLockRolling;
		}

		if (targetObj && targetFocus)
		{

			if (!disableSteering && !isLock && !isLockRolling)
			{
				req_xSpeed += (Input.GetAxis("Mouse X") * xSpeed * 0.02f - req_xSpeed) * Time.fixedDeltaTime * 10;
				req_ySpeed += (Input.GetAxis("Mouse Y") * ySpeed * 0.02f - req_ySpeed) * Time.fixedDeltaTime * 10;
			}
			else
			{
				req_xSpeed += (0 - req_xSpeed) * Time.fixedDeltaTime * 4;
				req_ySpeed += (0 - req_ySpeed) * Time.fixedDeltaTime * 4;
			}

			req_ObjRotateSpeed += (0 - req_ObjRotateSpeed) * Time.fixedDeltaTime * 4;

			//bool IsMouseOverGameWindow = !(0 > Input.mousePosition.x || 0 > Input.mousePosition.y || Screen.width < Input.mousePosition.x || Screen.height < Input.mousePosition.y);
			if (!isLock && !isLockRolling)
			{
				distance -= Input.GetAxis("Mouse ScrollWheel") * ZoomWheelSpeed;
				distance = Mathf.Clamp(distance, minDistance, maxDistance);
			}

			cur_ObjRotateSpeed += (req_ObjRotateSpeed - cur_ObjRotateSpeed) * Time.fixedDeltaTime * 20;

			cur_xSpeed += (req_xSpeed - cur_xSpeed) * Time.fixedDeltaTime * 20;
			cur_ySpeed += (req_ySpeed - cur_ySpeed) * Time.fixedDeltaTime * 20;
			x += cur_xSpeed;
			y -= cur_ySpeed;

			y = ClampAngle(y, yMinLimit + normal_angle, yMaxLimit + normal_angle);

			cur_distance = Mathf.Lerp(cur_distance, distance, Time.fixedDeltaTime * 4);

			if (!isLock)
			{
				Quaternion rotation = Quaternion.Euler(y, x, 0);
				Vector3 position = rotation * new Vector3(0.0f + offset, 0.0f + height, -cur_distance) + targetFocus.position;
				transform.rotation = rotation;
				transform.position = position;
			}
		}
	}

	static float ClampAngle(float angle, float min, float max)
	{
		if (angle < -360)
			angle += 360;
		if (angle > 360)
			angle -= 360;
		return Mathf.Clamp(angle, min, max);
	}

	public void set_normal_angle(float a)
	{
		normal_angle = a;
	}
}