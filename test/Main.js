// We're just returning an object that doesn't do requestAnimationFrame,
// so that the polyfill will be applied. We do it effectfully so that
// we can control when a fresh polyfill happens (otherwise, a previous
// test affects when the next animation frame is due).
exports.fakeWindow = function () {
    return function () {
        return {};
    };
};
