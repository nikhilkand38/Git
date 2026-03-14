#ifdef WINAMS_STUB
#ifdef __cplusplus
extern "C" {
#endif

/* WINAMS_STUB[safety_controller.c:SafetyController_SelfTest:AMSTB_SafetyController_SelfTest:inout:::] */
/*    SafetyController_SelfTest => Stub */
int AMSTB_SafetyController_SelfTest(int simulatedSensor)
{
	static int volatile AMIN_return;
	static int volatile AMOUT_simulatedSensor;
	AMOUT_simulatedSensor = simulatedSensor;
	return AMIN_return;
}

#ifdef __cplusplus
}
#endif
#endif /* WINAMS_STUB */
